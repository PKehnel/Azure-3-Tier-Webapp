locals {
  naming_prefix       = "${var.env}-${var.stage}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_resource_group" "rg" {
  name = "${local.naming_prefix}-rg"
}

data "template_file" "nginx_vm_cloud_init" {
  template = file("${path.module}/install-nginx.sh")
}

data "azurerm_log_analytics_workspace" "log_ws" {
  name                = "${local.naming_prefix}-${var.log_ws_name}"
  resource_group_name = local.resource_group_name
}


data "azurerm_subnet" "subnet_web" {
  name                 = "${local.naming_prefix}-subnet_${var.webserver_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = "${local.naming_prefix}-${var.vnet_name}"
}

#Create an availability set with two fault/update domains, so each webserver is placed into its own domain
resource "azurerm_availability_set" "avset" {
  name                         = "${local.naming_prefix}-avset"
  location                     = data.azurerm_resource_group.rg.location
  resource_group_name          = data.azurerm_resource_group.rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_virtual_machine" "web_servers" {
  count                 = var.webserver_count
  name                  = "${local.naming_prefix}-webserver-${count.index}"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  availability_set_id   = azurerm_availability_set.avset.id
  network_interface_ids = [element(azurerm_network_interface.nic_webservers.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

  # Delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "webserver-${count.index}"
    admin_username = "${local.naming_prefix}-${var.webserver_name}-${count.index}-admin"
    admin_password = azurerm_key_vault_secret.webserver-secret.value
    custom_data    = base64encode(data.template_file.nginx_vm_cloud_init.rendered)
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "uc3-demo"
  }
}

# Create 2 FrontEnd NICs for the webservers in the web subnet
resource "azurerm_network_interface" "nic_webservers" {
  count               = 2
  name                = "webnic-${count.index}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = data.azurerm_subnet.subnet_web.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine_extension" "vm_ext_web" {
  count = var.webserver_count
  name                 = "OmsAgentForLinux"
  virtual_machine_id   = azurerm_virtual_machine.web_servers[count.index].id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "OmsAgentForLinux"
  type_handler_version = "1.12"
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

data "azurerm_key_vault" "vault" {
  name                = "${local.naming_prefix}-keyvault"
  resource_group_name = local.resource_group_name
}


# Generate a password for webserver
resource "random_string" "webserver_password" {
  length      = 14
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}

resource "azurerm_key_vault_secret" "webserver-secret" {
  name         = "${local.naming_prefix}-webserver-secret"
  value        = random_string.webserver_password.result
  key_vault_id = data.azurerm_key_vault.vault.id
}