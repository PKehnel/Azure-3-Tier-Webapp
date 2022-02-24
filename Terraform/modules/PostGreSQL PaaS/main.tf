locals {
  naming_prefix = "${var.env}-${var.stage}"
  location      = data.azurerm_resource_group.rg.location
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "vault" {
  name                = var.vault_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${local.naming_prefix}-subnet_${var.postGreSQL_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.cidr]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "delegation postgress zone"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "${var.postGreSQL_name}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "virtual_network_link" {
  name                  = "${local.naming_prefix}-virtual_network_link"
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  resource_group_name   = var.resource_group_name
}


resource "random_string" "random_suffix" {
  length    = 4
  special   = false
  lower     = true
  min_lower = 4
}

# Create the PostGreSQL database as PaaS service.

resource "azurerm_postgresql_flexible_server" "postGreSQL" {
  name                = "${local.naming_prefix}-${var.postGreSQL_name}-${random_string.random_suffix.result}"
  location            = local.location
  resource_group_name = var.resource_group_name

  version                = "12"
  administrator_login    = "${var.env}_${var.stage}_postgresql"
  administrator_password = azurerm_key_vault_secret.postGreSQL_secret.value
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D4s_v3"

  delegated_subnet_id = azurerm_subnet.subnet.id
  private_dns_zone_id = azurerm_private_dns_zone.dns_zone.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.virtual_network_link]
  tags = var.standard_tags
}

# Generate a password for the postgres DB
resource "random_string" "postGreSQL_password" {
  length      = 14
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}

resource "azurerm_key_vault_secret" "postGreSQL_secret" {
  name         = "${local.naming_prefix}-postGreSQL-secret"
  value        = random_string.postGreSQL_password.result
  key_vault_id = data.azurerm_key_vault.vault.id
}