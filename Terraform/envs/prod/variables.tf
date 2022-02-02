variable "azure_region" { default = "westeurope" }
variable "env" { default = "case3" }
variable "stage" { default = "prod" }
variable "standard_tags" {
  default = { env = "case3", stage = "dev" }
}

variable "webserver_name" { default = "webserver" }
variable "webserver_count" { default = 3 }
variable "app_gateway_name" { default = "app-gateway" }
variable "postGreSQL_name" { default = "postGreSQL_db" }
variable "bastionhost_name" { default = "BastionHost" }
