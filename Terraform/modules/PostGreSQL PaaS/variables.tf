variable "env" {}
variable "stage" {}
variable "vault_name" {}
variable "subnet_name" { default = null}
variable "resource_group_name" {}
variable "virtual_network_name" {}

variable "log_ws_name" { default = "loganalyticsWS"}
variable "postGreSQL_name" { default = "db" }

variable "standard_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

