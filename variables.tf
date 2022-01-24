#User vars
variable "azure_region" { default = "westeurope" }
variable "env" { default = "rg-usecase3" }
variable "website" { default = "usecase3" }

variable "ports" {
  type    = list(string)
  default = ["22", "80"]
}

