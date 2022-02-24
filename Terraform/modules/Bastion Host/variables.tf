variable "env" {}
variable "stage" {}
variable "resource_group_name" {}
variable "virtual_network_name" {}

variable "bastionhost_name" { default = "BastionHost" }

variable "standard_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

