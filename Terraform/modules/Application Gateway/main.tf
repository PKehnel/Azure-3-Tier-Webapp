locals {
  naming_prefix = "${var.env}-${var.stage}"
  location      = data.azurerm_resource_group.rg.location

  backend_address_pool_name      = "${local.naming_prefix}-${var.virtual_network_name}-beap"
  frontend_port_name             = "${local.naming_prefix}-${var.virtual_network_name}-feport"
  frontend_ip_configuration_name = "${local.naming_prefix}-${var.virtual_network_name}-feip"
  http_setting_name              = "${local.naming_prefix}-${var.virtual_network_name}-be-htst"
  https_setting_name             = "${local.naming_prefix}-${var.virtual_network_name}-be-httpsst"
  listener_name_http             = "${local.naming_prefix}-${var.virtual_network_name}-httplstn"
  listener_name_https            = "${local.naming_prefix}-${var.virtual_network_name}-httpslstn"
  request_routing_rule_name      = "${local.naming_prefix}-${var.virtual_network_name}-rqrt"
  redirect_configuration_name    = "${local.naming_prefix}-${var.virtual_network_name}-rdrcfg"
}

data "azurerm_key_vault" "vault" {
  name                = var.vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_certificate" "certificate" {
  name         = "${local.naming_prefix}-cert"
  key_vault_id = data.azurerm_key_vault.vault.id
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = "${local.naming_prefix}-subnet_${var.subnet_name != null ? var.subnet_name : var.app_gateway_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}


#Create the PIP for the application gateway
resource "azurerm_public_ip" "pip_gw" {
  name                = "publicIPForGW"
  location            = local.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}


#Create the Application Gateway
resource "azurerm_application_gateway" "appgw" {
  name                = var.app_gateway_name
  location            = local.location
  resource_group_name = var.resource_group_name


  sku {
    name     = "Standard_V2"
    tier     = "Standard_V2"
    capacity = var.webserver_count
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.agw.id]
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = data.azurerm_subnet.subnet.id
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
    name = local.backend_address_pool_name
  }

  ssl_certificate {
    name                = data.azurerm_key_vault_certificate.certificate.name
    key_vault_secret_id = data.azurerm_key_vault_certificate.certificate.secret_id
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
    host_name             = "${var.webserver_name[0]}.azurewebsites.net"
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
    ssl_certificate_name           = data.azurerm_key_vault_certificate.certificate.name
  }

  request_routing_rule {
    name               = local.request_routing_rule_name
    rule_type          = "Basic"
    http_listener_name = local.listener_name_http
    #backend_address_pool_name  = local.backend_address_pool_name
    #backend_http_settings_name = local.http_setting_name
    redirect_configuration_name = local.redirect_configuration_name
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

  tags = var.standard_tags
}

data "azurerm_network_interface" "nic_webservers" {
  count               = var.webserver_count
  name                = "nic-${var.webserver_name[count.index]}"
  resource_group_name = var.resource_group_name
}

# binding happens here
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic_2_gw_binding" {
  count                   = var.webserver_count
  network_interface_id    = data.azurerm_network_interface.nic_webservers[count.index].id
  ip_configuration_name   = "IPConfiguration"
  backend_address_pool_id = azurerm_application_gateway.appgw.backend_address_pool[0].id
}

data "azurerm_user_assigned_identity" "agw" {
  name                = "agw-msi"
  resource_group_name = var.resource_group_name
}