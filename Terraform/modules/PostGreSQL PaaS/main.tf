locals {
  naming_prefix       = "${var.env}-${var.stage}"
  location            = data.azurerm_resource_group.rg.location
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

#Create the subnet that holds the db-servers
data "azurerm_subnet" "subnet" {
  name                 = "${local.naming_prefix}-subnet_${var.subnet_name != null ? var.subnet_name : var.postGreSQL_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}

data "azurerm_key_vault" "vault" {
  name                = var.vault_name
  resource_group_name = var.resource_group_name
}

resource "random_string" "random_suffix" {
  length    = 4
  special   = false
  lower     = true
  min_lower = 4
}

# Create the mySQL database as PaaS service. Must be General Purpose SKU to be able to use Private Link service
resource "azurerm_postgresql_flexible_server" "postGreSQL" {
  # unique name is required
  name                = "${local.naming_prefix}-postgresql-${random_string.random_suffix.result}"
  location            = local.location
  resource_group_name = var.resource_group_name

  sku_name   = "GP_Gen5_4"
  version    = "9.6"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  # Apparently hyphens ("-") are not allowed in the name.
  administrator_login           = "${var.env}_${var.stage}_postgresql"
  administrator_login_password  = azurerm_key_vault_secret.postGreSQL_secret.value

  tags = var.standard_tags

}

# Create a private endpoint in the DB subnet and link it to the postGreSQL database
resource "azurerm_private_endpoint" "ep_postGreSQL" {
  name                = "${local.naming_prefix}-postGreSQL-endpoint"
  location            = local.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "${local.naming_prefix}-postGreSQL-privateserviceconnection"
    private_connection_resource_id = azurerm_postgresql_server.postGreSQL.id
    subresource_names              = ["postGreSQLServer"]
    is_manual_connection           = false
  }
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