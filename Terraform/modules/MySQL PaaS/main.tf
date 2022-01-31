locals {
  naming_prefix       = "${var.env}-${var.stage}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_resource_group" "rg" {
  name = "${local.naming_prefix}-rg"
}

#Create the subnet that holds the db-servers
data "azurerm_subnet" "subnet" {
  name                                           = "${local.naming_prefix}-subnet_${var.mysql_name}"
  resource_group_name                            = local.resource_group_name
  virtual_network_name                           = "${local.naming_prefix}-${var.vnet_name}"
}

data "azurerm_key_vault" "vault" {
  name                = var.vault-name
  resource_group_name = local.resource_group_name
}

# Create the mySQL database as PaaS service. Must be General Purpose SKU to be able to use Private Link service
resource "azurerm_mysql_server" "mysql" {
  name                = "${local.naming_prefix}-mysql"
  location            = local.location
  resource_group_name = local.resource_group_name

  sku_name = "GP_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  public_network_access_enabled = false
  administrator_login           = "${local.naming_prefix}-mysql"
  administrator_login_password  = azurerm_key_vault_secret.mysql_secret.value
  version                       = "5.7"
  ssl_enforcement_enabled       = true
}

# Create a private endpoint in the DB subnet and link it to the mysql database
resource "azurerm_private_endpoint" "ep_mysql" {
  name                = "${local.naming_prefix}-mysql-endpoint"
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "${local.naming_prefix}-mysql-privateserviceconnection"
    private_connection_resource_id = azurerm_mysql_server.mysql.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }
}

# Generate a password for the postgres DB
resource "random_string" "mysql_password" {
  length      = 14
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}

resource "azurerm_key_vault_secret" "mysql_secret" {
  name         = "${local.naming_prefix}-mysql-secret"
  value        = random_string.mysql_password.result
  key_vault_id = data.azurerm_key_vault.vault.id
}