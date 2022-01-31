module "Vnet" {
  source = "../../modules/VNet"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env

  address_space = "10.0.0.0/16"
  subnets = [
    {
      name_suffix                   = var.app_gateway_name
      cidr                          = "10.0.0.0/24"
      disable_private_endpoint_only = false
    },
    {
      name_suffix                   = "AzureBastionSubnet" # This is mandatory for Bastion subnet
      cidr                          = "10.0.1.0/24"
      disable_private_endpoint_only = false
    },
    {
      name_suffix                   = var.webserver_name
      cidr                          = "10.0.2.0/24"
      disable_private_endpoint_only = false
    },

    {
      name_suffix                   = var.mysql_name
      cidr                          = "10.0.3.0/24"
      disable_private_endpoint_only = true
    },

    {
      name_suffix                   = var.postGresSQL_name
      cidr                          = "10.0.4.0/24"
      disable_private_endpoint_only = false
  }, ]
}

module "Azure_Key_Vault" {
  source = "../../modules/Azure Key Vault"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  depends_on   = [module.Vnet, ]
}

module "Application_Gateway" {
  source = "../../modules/Application Gateway"

  azure_region     = var.azure_region
  stage            = var.stage
  env              = var.env
  app_gateway_name = var.app_gateway_name
  webserver_name   = var.webserver_name
  vault-name    = module.Azure_Key_Vault.vault_name
  depends_on       = [module.Vnet, module.VSI_Webserver]
}

module "Bastion_Host" {
  source = "../../modules/Bastion Host"

  azure_region     = var.azure_region
  stage            = var.stage
  env              = var.env
  bastionhost_name = var.bastionhost_name
  depends_on       = [module.Vnet, ]
}

module "VSI_Webserver" {
  source = "../../modules/Virtual Server Instance"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  vault-name    = module.Azure_Key_Vault.vault_name
  virtual_server_name = var.webserver_name
  depends_on          = [module.Vnet]
}

module "MySQL_PaaS" {
  source = "../../modules/MySQL PaaS"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  mysql_name   = var.mysql_name
  vault-name    = module.Azure_Key_Vault.vault_name
  depends_on   = [module.Vnet]
}

module "VSI_DB" {
  source = "../../modules/Virtual Server Instance"

  azure_region         = var.azure_region
  stage                = var.stage
  env                  = var.env
  virtual_server_name  = var.postGresSQL_name
  virtual_server_count = var.postGresSQL_db_count
  vault-name    = module.Azure_Key_Vault.vault_name
  depends_on           = [module.Vnet]
}



