#User vars
variable "azure_region" { default = "westeurope" }
variable "env" { default = "rg-usecase3" }
variable "website" { default = "usecase3" }

variable "ports" {
  type    = list(string)
  default = ["22", "80"]
}

variable "webserver_count" {
  description = "Number of web server to provision."
  type        = number
  default     = 2
}

variable "dbserver_count" {
  description = "Number of db server to provision."
  type        = number
  default     = 1
}

