variable "azure_region" { default = "westeurope" }
variable "env" { default = "usecase3" }
variable "stage" { default = "dev" }
variable "vnet_name" { default = "vnet" }
variable "vault_name" {}

variable "subnet_name" { default = null}

variable "virtual_server_name" { default = "webserver" }
variable "virtual_server_count" { default = 2 }

variable "log_ws_name" { default = "loganalyticsWS" }
variable "script" { default = "install-nginx.sh" }

variable "vm_size" {
  description = "Specifies the size of the Virtual Machine e.g. Standard_D4_v3. See also Azure VM Naming Conventions"
  # https://docs.microsoft.com/en-gb/azure/virtual-machines/sizes-general)
  # https://docs.microsoft.com/en-gb/azure/virtual-machines/vm-naming-conventions
  default     = "Standard_DS1_v2"
}