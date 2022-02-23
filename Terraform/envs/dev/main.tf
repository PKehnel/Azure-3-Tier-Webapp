module "Vnet" {
  source = "../../modules/VNet"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env

  address_space = "10.0.0.0/16"
  standard_tags = var.tags
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
    {
      name_suffix                   = "ansible"
      cidr                          = "10.0.4.0/24"
      disable_private_endpoint_only = true
    }
  ]
}

module "Azure_Key_Vault" {
  source = "../../modules/Azure Key Vault"

  stage          = var.stage
  env            = var.env
  webserver_name = var.webserver_name

  resource_group_name  = module.Vnet.resource_group_name
  virtual_network_name = module.Vnet.vnet_name

  depends_on = [module.Vnet]

}


module "Bastion_Host" {
  source = "../../modules/Bastion Host"

  stage            = var.stage
  env              = var.env
  bastionhost_name = var.bastionhost_name

  resource_group_name  = module.Vnet.resource_group_name
  virtual_network_name = module.Vnet.vnet_name

  depends_on = [module.Vnet]
}

module "VSI_Webserver" {
  source = "../../modules/Virtual Server Instance"

  stage                = var.stage
  env                  = var.env
  vm_size              = "Standard_DS1_v2"
  virtual_server_name  = var.webserver_name
  virtual_server_count = var.webserver_count
  public_ssh_key       = module.Azure_Key_Vault.public_ssh_key_webserver
  vault_name           = module.Azure_Key_Vault.vault_name
  resource_group_name  = module.Vnet.resource_group_name
  virtual_network_name = module.Vnet.vnet_name

  depends_on = [module.Vnet]
}

module "Ansible" {
  source = "../../modules/Virtual Server Instance"

  stage                = var.stage
  env                  = var.env
  vm_size              = "Standard_DS1_v2"
  virtual_server_name  = "ansible"
  virtual_server_count = var.webserver_count
  vm_image = {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8-LVM"
    version   = "latest"
  }
  script = "install-redhat-test.sh"
  standard_tags = var.tags
  vault_name           = module.Azure_Key_Vault.vault_name
  public_ssh_key       = module.Azure_Key_Vault.public_ssh_key_webserver
  resource_group_name  = module.Vnet.resource_group_name
  virtual_network_name = module.Vnet.vnet_name

  depends_on = [module.Vnet]
}

module "Application_Gateway" {
  source = "../../modules/Application Gateway"

  stage            = var.stage
  env              = var.env
  app_gateway_name = var.app_gateway_name
  webserver_count = var.webserver_count

  webserver_name       = module.VSI_Webserver.virtual_server_name
  vault_name           = module.Azure_Key_Vault.vault_name
  resource_group_name  = module.Vnet.resource_group_name
  virtual_network_name = module.Vnet.vnet_name

  depends_on = [module.Vnet, module.Azure_Key_Vault]
}

#module "PostGreSQL_PaaS" {
#  source = "../../modules/PostGreSQL PaaS"
#
#  stage           = var.stage
#  env             = var.env
#  postGreSQL_name = var.postGreSQL_name
#  vault_name      = module.Azure_Key_Vault.vault_name
#
#  resource_group_name  = module.Vnet.resource_group_name
#  virtual_network_name = module.Vnet.vnet_name
#
#  depends_on = [module.Vnet]
#}


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



