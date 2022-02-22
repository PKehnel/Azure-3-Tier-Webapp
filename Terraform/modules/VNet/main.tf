locals {
  naming_prefix       = "${var.env}-${var.stage}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a resource group to hold all the resources
resource "azurerm_resource_group" "rg" {
  name     = "${local.naming_prefix}-rg"
  location = var.azure_region
  tags = merge(var.standard_tags,
  { type = "DemoEnv" }, )
}

# Create a LogAnalytics Workspace
resource "azurerm_log_analytics_workspace" "log_ws" {
  name                = "${local.naming_prefix}-${var.log_ws_name}"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 180
}

# Create the VM INsights Log Analytics Solution to collect additional metrics for VMs
resource "azurerm_log_analytics_solution" "vminsights" {
  solution_name         = "VMInsights"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.log_ws.id
  workspace_name        = azurerm_log_analytics_workspace.log_ws.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }
}

# Create the VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.naming_prefix}-${var.vnet_name}"
  address_space       = [var.address_space]
  location            = local.location
  resource_group_name = local.resource_group_name
}

# Create the subnets by iterating over the variable subnets
resource "azurerm_subnet" "subnet" {
  for_each             = { for key, value in var.subnets : key => value }
  name                 = each.value.name_suffix != "AzureBastionSubnet" ? "${local.naming_prefix}-subnet_${each.value.name_suffix}" : "AzureBastionSubnet"
  address_prefixes     = [each.value.cidr]
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  # required to be set to true, when using NSG as they are not integrated atm
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

  enforce_private_link_endpoint_network_policies = each.value.disable_private_endpoint_only
}