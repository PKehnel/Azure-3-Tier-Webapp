 # IaC module to deploy a 2-Tier IaaS infrastructure in Azure
 # Tier 1: Web-Layer consisting of 2 Load Balanced Web Servers
 # Tier 2: DB-Layer with a Postgres DB
 #
 # Note: The web-site is static so there will be no actual app-db
 #       communication between the web-servers and the DB. 
 #       It is used for demo purposes only
 
 
 terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}

}

# Bootstrapping Template File
data "template_file" "nginx_vm_cloud_init" {
  template = file("install-nginx.sh")
}

#Create a resource group to hold all the resources
resource "azurerm_resource_group" "rg" {
  name     = "${var.env}"
  location = "${var.azure_region}"
}

#Create a LogAnalytics Workspace
resource "azurerm_log_analytics_workspace" "log_ws" {
  name                = "log-ws-uc3"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  sku                 = "PerGB2018"
  retention_in_days   = 180
}

#Create the VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-usecase3"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

#Create the subnet that holds the app-gateway
resource "azurerm_subnet" "subnet_gw" {
  name                 = "subnet-gw"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefixes     = ["10.0.0.0/24"]
}

#Create the subnet that holds the web-servers
resource "azurerm_subnet" "subnet_web" {
  name                 = "subnet-web"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefixes     = ["10.0.1.0/24"]
}

#Create the subnet that holds the db-servers
resource "azurerm_subnet" "subnet_db" {
  name                 = "subnet-db"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefixes     = ["10.0.2.0/24"]
}

#Create the PIP for the application gateway
resource "azurerm_public_ip" "pip_gw" {
  name                = "publicIPForGW"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Create 2 FrontEnd NICs for the webservers in the web subnet
resource "azurerm_network_interface" "nic_webservers" {
  count               = 2
  name                = "webnic-${count.index}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = azurerm_subnet.subnet_web.id
    private_ip_address_allocation = "dynamic"
  }
}

#Local definition of reused names for easier reference
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.vnet.name}-rdrcfg"
}

#Create the Application Gateway
resource "azurerm_application_gateway" "appgw" {
  name                = "AppGateway-UC3"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"


  sku {
    name     = "Standard_V2"
    tier     = "Standard_V2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = azurerm_subnet.subnet_gw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip_gw.id
  }

  backend_address_pool {
    name          = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    #path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

# binding happens here
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic_2_gw_binding" {
  count = 2
  network_interface_id    = "${azurerm_network_interface.nic_webservers[count.index].id}"
  ip_configuration_name   = "IPConfiguration"
  backend_address_pool_id = "${azurerm_application_gateway.appgw.backend_address_pool.0.id}"
}

#Create an availability set with two fault/update domains, so each webserver is placed into its own domain
resource "azurerm_availability_set" "avset" {
  name                          = "avset"
  location                      = "${azurerm_resource_group.rg.location}"
  resource_group_name           = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count   = 2
  platform_update_domain_count  = 2
  managed                       = true
}

resource "azurerm_virtual_machine" "web_servers" {
  count                 = 2
  name                  = "webserver-${count.index}"
  location              = "${azurerm_resource_group.rg.location}"
  availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic_webservers.*.id, count.index)}"]
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
    admin_username = "kyndryl"
    admin_password = "Password1234!"
    custom_data    = base64encode(data.template_file.nginx_vm_cloud_init.rendered)
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "uc3-demo"
  }
}

resource "azurerm_virtual_machine_extension" "vm_ext" {
  count = 2
  name                 = "OmsAgentForLinux"
  virtual_machine_id   = azurerm_virtual_machine.web_servers[count.index].id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "OmsAgentForLinux"
  type_handler_version = "1.12"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "workspaceId": "${azurerm_log_analytics_workspace.log_ws.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTEDSETTINGS
    {
        "workspaceKey": "${azurerm_log_analytics_workspace.log_ws.primary_shared_key}"
    }
  PROTECTEDSETTINGS
}