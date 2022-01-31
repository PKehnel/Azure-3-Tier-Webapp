variable "azure_region" { default = "westeurope" }
variable "env" { default = "usecase3" }
variable "stage" { default = "dev" }
variable "vnet_name" { default = "vnet"}

variable "virtual_server_name" { default = "webserver" }
variable "virtual_server_count" {default = 2}

variable "log_ws_name" { default = "loganalyticsWS"}
variable "script" {default = "install-nginx.sh"}

