locals {
  naming_prefix = "${var.env}-${var.stage}"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#Create a resource group to hold all the resources
resource "azurerm_resource_group" "rg" {
  name     = "${local.naming_prefix}-rg"
  location = var.azure_region
}

#Create a LogAnalytics Workspace
resource "azurerm_log_analytics_workspace" "log_ws" {
  name                = "${local.naming_prefix}-loganalyticsWS"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 180
}

#Create the VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.naming_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = local.resource_group_name
}

#Create the subnet that holds the app-gateway
resource "azurerm_subnet" "subnet_gw" {
  name                 = "${local.naming_prefix}-subnet_gw"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

#Create the subnet that holds the web-servers
resource "azurerm_subnet" "subnet_web" {
  name                 = "${local.naming_prefix}-subnet_webserver"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Create the subnet that holds the db-servers
resource "azurerm_subnet" "subnet_db" {
  name                 = "${local.naming_prefix}-subnet_db"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
