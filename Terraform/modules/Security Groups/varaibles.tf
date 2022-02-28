variable "env" {}
variable "stage" {}
variable "resource_group_name" {}


variable "standard_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

