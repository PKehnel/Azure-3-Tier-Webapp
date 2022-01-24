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
  https_setting_name             = "${azurerm_virtual_network.vnet.name}-be-httpsst"
  listener_name_http             = "${azurerm_virtual_network.vnet.name}-httplstn"
  listener_name_https            = "${azurerm_virtual_network.vnet.name}-httpslstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.vnet.name}-rdrcfg"
}

# Create a user assigned identity that represents the gateway for access to the vault
resource "azurerm_user_assigned_identity" "agw" {
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  name                = "agw-msi"
}

# -
# - Key Vault Configuration Start
# -

data "azurerm_client_config" "current" {}

resource "random_string" "random_name" {
  length = 8
  special = false
}

resource "azurerm_key_vault" "vault" {
  name                       = "keyvault${random_string.random_name.result}"
  location                   = "${azurerm_resource_group.rg.location}"
  resource_group_name        = "${azurerm_resource_group.rg.name}"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 90
  purge_protection_enabled   = false
  sku_name                   = "standard"

  # Allow access for Builder ID
  access_policy {
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = data.azurerm_client_config.current.object_id

    certificate_permissions = ["create", "get", "list"]
  }

  # Allow access from the gateway to access the certificate
  access_policy {
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = azurerm_user_assigned_identity.agw.principal_id

    certificate_permissions = ["get"]
    secret_permissions = ["get"]
  }

  network_acls {
      default_action = "Allow"
      bypass         = "AzureServices"
  }
}

# Create an access policy for the builder to create a certificate
#resource "azurerm_key_vault_access_policy" "terraformer" {
#  key_vault_id = azurerm_key_vault.vault.id
#  tenant_id    = data.azurerm_client_config.current.tenant_id
#  object_id    = data.azurerm_client_config.current.object_id

#  certificate_permissions = [
#    "create",
#    "get",
#    "list"
#  ]
#}

# Create an access policy for the below created gateway to access the certificate
#resource "azurerm_key_vault_access_policy" "agw" {
#  key_vault_id = azurerm_key_vault.vault.id
#  tenant_id    = data.azurerm_client_config.current.tenant_id
#  object_id    = azurerm_user_assigned_identity.agw.principal_id

#  certificate_permissions = [
#    "get"
#  ]

#  secret_permissions = [
#    "get"
#  ]
#}

# Create a self signed certificate
resource "azurerm_key_vault_certificate" "certificate" {
  name         = "cert-${var.website}"
  key_vault_id = azurerm_key_vault.vault.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["${var.website}.azurewebsites.net"]
      }

      subject            = "CN=${var.website}.azurewebsites.net"
      validity_in_months = 12
    }
  }
}

# Allows some time for the certificate to be created
resource "time_sleep" "wait_60_seconds" {
  depends_on = [azurerm_key_vault_certificate.certificate]

  create_duration = "60s"
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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw.id]
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = azurerm_subnet.subnet_gw.id
  }

  frontend_port {
    name = "${local.frontend_port_name}-80"
    port = 80
  }
  
  frontend_port {
    name = "${local.frontend_port_name}-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip_gw.id
  }

  backend_address_pool {
    name          = local.backend_address_pool_name
  }

  ssl_certificate {
    name                = azurerm_key_vault_certificate.certificate.name
    key_vault_secret_id = azurerm_key_vault_certificate.certificate.secret_id
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  backend_http_settings {
    name                  = local.https_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    host_name             = "${var.website}.azurewebsites.net"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name_http
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "${local.frontend_port_name}-80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = local.listener_name_https
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "${local.frontend_port_name}-443"
    protocol                       = "Https"
    ssl_certificate_name           = azurerm_key_vault_certificate.certificate.name
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_http
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  request_routing_rule {
    name                       = "${local.request_routing_rule_name}-https"
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_https
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  redirect_configuration {
    name                 = local.redirect_configuration_name
    redirect_type        = "Permanent"
    include_path         = true
    include_query_string = true
    target_listener_name = local.listener_name_https
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