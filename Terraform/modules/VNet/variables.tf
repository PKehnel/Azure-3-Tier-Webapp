variable "azure_region" {}
variable "env" {}
variable "stage" {}

variable "log_ws_name" { default = "loganalyticsWS" }

variable "vnet_name" { default = "vnet" }
variable "address_space" {}

variable "standard_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "subnets" {
  description = "subnets"
  type        = list(object({
    name_suffix = string
    cidr = string
    disable_private_endpoint_only = bool
  }))
}
