variable "azure_region" { default = "westeurope" }
variable "env" { default = "usecase3" }
variable "stage" { default = "dev" }
variable "vnet_name" { default = "vnet" }
variable "vault_name" {}
variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "subnet_name" { default = null }

variable "virtual_server_name" { default = "webserver" }
variable "virtual_server_count" { default = 2 }

variable "log_ws_name" { default = "loganalyticsWS" }
variable "script" { default = "install-nginx.sh" }

variable "vm_size" {
  description = "Specifies the size of the Virtual Machine e.g. Standard_D4_v3. See also Azure VM Naming Conventions"
  # https://docs.microsoft.com/en-gb/azure/virtual-machines/sizes-general)
  # https://docs.microsoft.com/en-gb/azure/virtual-machines/vm-naming-conventions
  default = "Standard_DS1_v2"
}

variable "vm_image" {
  description = "Define the OS (publisher, offer, sku, version)"
  # Publisher: Ubuntu → Canonical; RedHat → RedHat; CentOS → OpenLogic; SuSE Linux → SUSE; Debian → credativ; Oracle Linux → Oracle-Linux; CoreOS → CoreOS
  # The other 3 attributes can be found via:
  # az vm image list -f *Publisher_Name* --all
  default = {
    "publisher" = "Canonical"
    "offer"     = "UbuntuServer"
    "sku"       = "18.04-LTS"
    "version"   = "latest"
  }
}