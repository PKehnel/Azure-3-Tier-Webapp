variable "azure_region" { default = "westeurope" }
variable "env" { default = "usecase3" }
variable "stage" { default = "dev" }
variable "vnet_name" { default = "vnet"}
variable "vault_name" {}
variable "subnet_name" { default = null}
variable "resource_group_name" {}
variable "virtual_network_name" {}

variable "log_ws_name" { default = "loganalyticsWS"}
variable "postGreSQL_name" { default = "db" }



