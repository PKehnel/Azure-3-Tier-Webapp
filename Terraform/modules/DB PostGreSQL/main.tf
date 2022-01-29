locals {
  naming_prefix       = "${var.env}-${var.stage}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_resource_group" "rg" {
  name = "${local.naming_prefix}-rg"
}

data "azurerm_availability_set" "avset" {
  name                = "${local.naming_prefix}-avset"
  resource_group_name = local.resource_group_name
}

data "azurerm_key_vault" "vault" {
  name                = "${local.naming_prefix}-keyvault"
  resource_group_name = local.resource_group_name
}

data "azurerm_subnet" "subnet_db" {
  name                 = "${local.naming_prefix}-subnet_${var.database_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = "${local.naming_prefix}-${var.vnet_name}"
}

data "azurerm_log_analytics_workspace" "log_ws" {
  name                = "${local.naming_prefix}-${var.log_ws_name}"
  resource_group_name = local.resource_group_name
}

# Bootstrapping Template File for postgresql
data "template_file" "postgresql_vm_cloud_init" {
  template = file("${path.module}/install-postgresql.sh")
}

#Create a NIC for the db-server in the db subnet
resource "azurerm_network_interface" "nic_dbservers" {
  name                = "dbnic-${count.index}"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = data.azurerm_subnet.subnet_db.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "db_servers" {
  count                 = var.dbserver_count
  name                  = "${local.naming_prefix}-dbserver-${count.index}"
  location              = local.location
  availability_set_id   = data.azurerm_availability_set.avset.id
  resource_group_name   = local.resource_group_name
  network_interface_ids = [element(azurerm_network_interface.nic_dbservers.*.id, count.index)]
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
    name              = "db-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "dbserver-${count.index}"
    admin_username = "kyndryl"
    admin_password = "Password1234!"
    custom_data    = base64encode(data.template_file.postgresql_vm_cloud_init.rendered)
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "uc3-demo"
  }
}

resource "azurerm_virtual_machine_extension" "vm_ext_db" {
  count                      = var.dbserver_count
  name                       = "OmsAgentForLinux"
  virtual_machine_id         = azurerm_virtual_machine.db_servers[count.index].id
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

resource "azurerm_virtual_machine_extension" "da_db" {
  count                      = var.dbserver_count
  name                       = "DAExtension"
  virtual_machine_id         = azurerm_virtual_machine.db_servers[count.index].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true
}
