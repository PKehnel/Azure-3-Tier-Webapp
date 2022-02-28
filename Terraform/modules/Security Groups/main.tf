locals {
  naming_prefix = "${var.env}-${var.stage}"
  location      = data.azurerm_resource_group.rg.location
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_network_security_group" "Webserver" {
  name                = "Webserver"
  location            = local.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Application Gateway"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Database"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.standard_tags
}

resource "azurerm_network_security_group" "ApplicationGateway" {
  name                = "Application Gateway"
  location            = local.location
  resource_group_name = var.resource_group_name

    security_rule {
    name                       = "Webserver"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.standard_tags
}

resource "azurerm_network_security_group" "Database" {
  name                = "PostGreSQL"
  location            = local.location
  resource_group_name = var.resource_group_name

    security_rule {
    name                       = "Database"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.standard_tags
}