variable "env" {}
variable "stage" {}
variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "vault_name" {}
variable "webserver_name" {}

variable "subnet_name" { default = null }
variable "app_gateway_name" { default = "app_gateway" }
variable "webserver_count" {}




variable "standard_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}