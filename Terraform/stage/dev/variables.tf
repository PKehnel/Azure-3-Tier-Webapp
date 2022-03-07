variable "azure_region" { default = "West Europe" }
variable "env" { default = "case3" }
variable "stage" { default = "dev" }
variable "tags" {
  default = { env = "case3", stage = "dev" }
}

variable "webserver_name" { default = "webserver" }
variable "webserver_count" { default = 2 }
variable "app_gateway_name" { default = "app-gateway" }
variable "postGreSQL_name" { default = "postgresql-db" }
variable "bastionhost_name" { default = "BastionHost" }