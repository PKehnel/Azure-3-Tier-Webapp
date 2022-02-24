locals {
  naming_prefix = "${var.env}-${var.stage}"
  location      = data.azurerm_resource_group.rg.location
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_key_vault" "vault" {
  name                = var.vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "private_ssh_key" {
  count    = var.virtual_server_name != "ansible" ? 0 : 1
  name         = "private-ssh-key-servers"
  key_vault_id = data.azurerm_key_vault.vault.id
}

data "template_file" "init_script" {
  count    = var.virtual_server_name != "ansible" ? 0 : 1
  template = file("${path.module}/${var.script}")
  vars = {
    ssh_private_key = data.azurerm_key_vault_secret.private_ssh_key[0].value
    azure_secret = data.azurerm_key_vault_secret.azure_secret[0].value
  }
}

data "azurerm_log_analytics_workspace" "log_ws" {
  name                = "${local.naming_prefix}-${var.log_ws_name}"
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = "${local.naming_prefix}-subnet_${var.subnet_name != null ? var.subnet_name : var.virtual_server_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}

#Create an availability set with two fault/update domains, so each webserver is placed into its own domain
resource "azurerm_availability_set" "avset" {
  name                         = "${local.naming_prefix}-${var.virtual_server_name}-avset"
  resource_group_name          = var.resource_group_name
  location                     = local.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_virtual_machine" "virtual_servers" {
  count                 = var.virtual_server_count
  name                  = "${local.naming_prefix}-${var.virtual_server_name}-${count.index}"
  location              = local.location
  resource_group_name   = var.resource_group_name
  availability_set_id   = azurerm_availability_set.avset.id
  network_interface_ids = [element(azurerm_network_interface.nic_webservers.*.id, count.index)]
  vm_size               = var.vm_size

  # Delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.offer
    sku       = var.vm_image.sku
    version   = var.vm_image.version
  }

  storage_os_disk {
    name              = "disk-${count.index}-${var.virtual_server_name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  # User creation for Ansible
  os_profile {
    computer_name  = "${var.virtual_server_name}-${count.index}"
    admin_username = "${local.naming_prefix}-${var.virtual_server_name}-admin"
    admin_password = azurerm_key_vault_secret.virtual_server_secret.value
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      key_data = var.public_ssh_key
      path     = "/home/${local.naming_prefix}-${var.virtual_server_name}-admin/.ssh/authorized_keys"
    }
  }

  identity {
    type = "SystemAssigned"
  }
  tags = var.standard_tags
}

# Create FrontEnd NICs for the webservers in the web subnet
resource "azurerm_network_interface" "nic_webservers" {
  count               = var.virtual_server_count
  name                = "webnic-${local.naming_prefix}-${var.virtual_server_name}-${count.index}"
  location            = local.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine_extension" "vm_ext_web" {
  count                      = var.virtual_server_count
  name                       = "OmsAgentForLinux"
  virtual_machine_id         = azurerm_virtual_machine.virtual_servers[count.index].id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.12"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "workspaceId": "${data.azurerm_log_analytics_workspace.log_ws.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTEDSETTINGS
    {
        "workspaceKey": "${data.azurerm_log_analytics_workspace.log_ws.primary_shared_key}"
    }
  PROTECTEDSETTINGS
}

resource "azurerm_virtual_machine_extension" "da_web" {
  count                      = var.virtual_server_count
  name                       = "DAExtension"
  virtual_machine_id         = azurerm_virtual_machine.virtual_servers[count.index].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true
}

# Generate a password for webserver
resource "random_string" "virtual_server_password" {
  length      = 14
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}

resource "azurerm_key_vault_secret" "virtual_server_secret" {
  name         = "${local.naming_prefix}-secret-${var.virtual_server_name}"
  value        = random_string.virtual_server_password.result
  key_vault_id = data.azurerm_key_vault.vault.id
}

resource "azurerm_virtual_machine_extension" "startup" {
  count                = var.virtual_server_name != "ansible" ? 0 : 1
  name                 = "startup"
  virtual_machine_id   = azurerm_virtual_machine.virtual_servers[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<PROT
    {
        "script": "${base64encode(data.template_file.init_script[0].rendered)}"
    }
    PROT
}

# Pull existing Key Vault from Azure

data "azurerm_key_vault" "infra-vault" {
  name                = "key-vault-uit-case-3"
  resource_group_name = "infra-rg"
}

# Azure Credentials required for Ansible service connection
data "azurerm_key_vault_secret" "azure_secret" {
  count    = var.virtual_server_name != "ansible" ? 0 : 1
  name         = "secret"
  key_vault_id = data.azurerm_key_vault.infra-vault.id
}

# Create User Managed Identity
#resource "azurerm_user_assigned_identity" "uai" {
#  name                = "UAI-DEMO"
#  resource_group_name = var.resource_group_name
#  location            = local.location
#  tags = var.standard_tags
#}

# Assign UAI to KV access policy
#resource "azurerm_key_vault_access_policy" "kvaccess" {
#  key_vault_id = data.azurerm_key_vault.infra-vault.id
#  tenant_id    = data.azurerm_client_config.current.tenant_id
#  object_id    = data.azurerm_client_config.current.object_id
#
#  secret_permissions = [
#    "Get", "List",
#  ]
#
#}