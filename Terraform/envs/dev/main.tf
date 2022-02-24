module "Vnet" {
  source = "../../modules/VNet"

  azure_region = var.azure_region
  stage        = var.stage
  env          = var.env

  address_space = "10.0.0.0/16"
  standard_tags = var.tags
  # the subnet "10.0.3.0/24" for the PostGreSQL Database is directly created in the module, as it requires delegation
  # and no other resources are allowed to be placed in that subnet.

  subnets = [
    {
      name_suffix = var.app_gateway_name
      cidr        = "10.0.0.0/24"
    },
    {
      name_suffix = "AzureBastionSubnet" # This is mandatory for Bastion subnet
      cidr        = "10.0.1.0/24"
    },
    {
      name_suffix = var.webserver_name
      cidr        = "10.0.2.0/24"

    },
    {
      name_suffix = "ansible"
      cidr        = "10.0.4.0/24"
    }
  ]
}

module "Azure_Key_Vault" {
  source = "../../modules/Azure Key Vault"

  stage          = var.stage
  env            = var.env
  webserver_name = var.webserver_name

  standard_tags        = var.tags
  resource_group_name  = module.Vnet.resource_group_name
  virtual_network_name = module.Vnet.vnet_name

  depends_on = [module.Vnet]

}


module "Bastion_Host" {
  source = "../../modules/Bastion Host"

  stage            = var.stage
  env              = var.env
  bastionhost_name = var.bastionhost_name
  standard_tags    = var.tags

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
  standard_tags        = var.tags

  public_ssh_key       = module.Azure_Key_Vault.public_ssh_key_webserver
  vault_name           = module.Azure_Key_Vault.vault_name
  resource_group_name  = module.Vnet.resource_group_name
  virtual_network_name = module.Vnet.vnet_name

  depends_on = [module.Vnet, module.Azure_Key_Vault]
}

#module "Ansible" {
#  source = "../../modules/Virtual Server Instance"
#
#  stage                = var.stage
#  env                  = var.env
#  vm_size              = "Standard_DS1_v2"
#  virtual_server_name  = "ansible"
#  vm_image = {
#    publisher = "RedHat"
#    offer     = "RHEL"
#    sku       = "8-LVM"
#    version   = "latest"
#  }
#  script        = "install-ansible.sh"
#  standard_tags = var.tags
#
#  vault_name           = module.Azure_Key_Vault.vault_name
#  public_ssh_key       = module.Azure_Key_Vault.public_ssh_key_webserver
#  resource_group_name  = module.Vnet.resource_group_name
#  virtual_network_name = module.Vnet.vnet_name
#
#  depends_on = [module.Vnet, module.Azure_Key_Vault]
#}

module "Application_Gateway" {
  source = "../../modules/Application Gateway"

  stage            = var.stage
  env              = var.env
  app_gateway_name = var.app_gateway_name
  webserver_count  = var.webserver_count

  webserver_name       = module.VSI_Webserver.virtual_server_name
  vault_name           = module.Azure_Key_Vault.vault_name
  resource_group_name  = module.Vnet.resource_group_name
  virtual_network_name = module.Vnet.vnet_name

  depends_on = [module.Vnet, module.Azure_Key_Vault]
}

module "PostGreSQL_PaaS" {
  source = "../../modules/PostGreSQL PaaS"

  stage           = var.stage
  env             = var.env
  postGreSQL_name = var.postGreSQL_name
  cidr            = "10.0.3.0/24"
  vault_name      = module.Azure_Key_Vault.vault_name

  resource_group_name  = module.Vnet.resource_group_name
  virtual_network_name = module.Vnet.vnet_name

  depends_on = [module.Vnet, module.Azure_Key_Vault]
}


