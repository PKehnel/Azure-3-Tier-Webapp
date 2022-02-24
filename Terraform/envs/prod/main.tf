module "Vnet" {
  source = "../../modules/VNet"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env

  address_space = "10.0.0.0/16"
  subnets = [
    {
      name_suffix                   = var.postGreSQL_name
      cidr                          = "10.0.3.0/24"
      disable_private_endpoint_only = true
    },
  ]
}

module "PostGreSQL_PaaS" {
  source = "../../modules/PostGreSQL PaaS"

  stage           = var.stage
  env             = var.env
  postGreSQL_name = var.postGreSQL_name

  resource_group_name  = module.Vnet.resource_group_name
  virtual_network_name = module.Vnet.vnet_name

  depends_on = [module.Vnet]
}