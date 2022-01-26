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