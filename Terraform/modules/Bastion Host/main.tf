locals {
  naming_prefix       = "${var.env}-${var.stage}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_resource_group" "rg" {
  name = "${local.naming_prefix}-rg"
}

# Create the subnet that holds the for the bastion service
data "azurerm_subnet" "subnet" {
  name                 = "AzureBastionSubnet" # This name is predefined by Azure
  resource_group_name  = local.resource_group_name
  virtual_network_name = "${local.naming_prefix}-${var.vnet_name}"
}

#Create the PIP for the bastion
resource "azurerm_public_ip" "pip_bastion" {
  name                = "publicIPForBastion"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Create the bastion servie in the bastion subnet
resource "azurerm_bastion_host" "bastion" {
  name                = var.bastionhost_name
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                 = "IPConfiguration"
    subnet_id            = data.azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.pip_bastion.id
  }
}
