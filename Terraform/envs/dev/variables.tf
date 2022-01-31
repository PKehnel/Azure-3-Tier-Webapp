variable "azure_region" { default = "westeurope" }
variable "env" { default = "case3" }
variable "stage" { default = "dev" }
variable "standard_tags" {
  default = { env = "usecase3", stage = "dev" }
}

variable "webserver_name" { default = "webserver" }
variable "webserver_count" { default = 2 }
variable "app_gateway_name" { default = "app-gateway" }
variable "mysql_name" { default = "mysql_db" }
variable "bastionhost_name" { default = "BastionHost" }
variable "postGresSQL_name" { default = "PostGresSQLDB" }
variable "postGresSQL_db_count" { default = 1 }