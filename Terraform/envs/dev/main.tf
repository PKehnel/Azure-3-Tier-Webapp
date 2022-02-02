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
      name_suffix                   = var.postGreSQL_name
      cidr                          = "10.0.3.0/24"
      disable_private_endpoint_only = true
    },
 ]
}

module "Azure_Key_Vault" {
  source = "../../modules/Azure Key Vault"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  depends_on   = [module.Vnet, ]
}

#module "Application_Gateway" {
#  source = "../../modules/Application Gateway"
#
#  azure_region     = var.azure_region
#  stage            = var.stage
#  env              = var.env
#  app_gateway_name = var.app_gateway_name
#  webserver_name   = var.webserver_name
#  vault_name       = module.Azure_Key_Vault.vault_name
#  depends_on       = [module.Vnet, module.VSI_Webserver]
#}
#
#module "Bastion_Host" {
#  source = "../../modules/Bastion Host"
#
#  azure_region     = var.azure_region
#  stage            = var.stage
#  env              = var.env
#  bastionhost_name = var.bastionhost_name
#  depends_on       = [module.Vnet, ]
#}
#
#module "VSI_Webserver" {
#  source = "../../modules/Virtual Server Instance"
#
#  azure_region        = var.azure_region
#  stage               = var.stage
#  env                 = var.env
#  vm_size             = "Standard_DS1_v2"
#  vault_name          = module.Azure_Key_Vault.vault_name
#  virtual_server_name = var.webserver_name
#  depends_on          = [module.Vnet]
#}

module "PostGreSQL_PaaS" {
  source = "../../modules/PostGreSQL PaaS"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  postGreSQL_name   = var.postGreSQL_name
  vault_name   = module.Azure_Key_Vault.vault_name
  depends_on   = [module.Vnet]
}


# PostgreSQL DB could also be setup via VSI with a install script
#module "VSI_DB" {
#  source = "../../modules/Virtual Server Instance"
#
#  azure_region         = var.azure_region
#  stage                = var.stage
#  env                  = var.env
#  virtual_server_name  = var.postGreSQL_name
#  virtual_server_count = var.postGreSQL_db_count
#  subnet_name          = var.postGreSQL_name
#  script               = "install-postgresql.sh"
#  vault_name           = module.Azure_Key_Vault.vault_name
#  depends_on           = [module.Vnet]
#}



