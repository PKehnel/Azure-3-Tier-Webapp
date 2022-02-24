variable "env" {}
variable "stage" {}
variable "resource_group_name" {}
variable "virtual_network_name" {}

variable "webserver_name" {}

variable "standard_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}