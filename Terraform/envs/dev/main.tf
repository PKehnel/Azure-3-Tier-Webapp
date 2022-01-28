module "Vnet" {
  source = "../../modules/VNet"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
}

module "VSI_Webserver" {
  source = "../../modules/VSI Webserver"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  depends_on = [ module.Vnet, ]
}

module "Azure_Key_Vault" {
  source = "../../modules/Azure Key Vault"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  depends_on = [ module.Vnet, ]
}

module "PostGresSQL" {
  source = "../../modules/DB PostGreSQL"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  depends_on = [ module.Vnet, module.Azure_Key_Vault ]
}

module "MySQL_SaaS" {
  source = "../../modules/MySQL SaaS"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  depends_on = [ module.Vnet, module.Azure_Key_Vault ]
}

module "Bastion_Host" {
  source = "../../modules/Bastion Host"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  depends_on = [ module.Vnet, ]
}

module "Application_Gateway" {
  source = "../../modules/Application Gateway"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env
  depends_on = [ module.Vnet, module.Azure_Key_Vault, module.VSI_Webserver ]
}