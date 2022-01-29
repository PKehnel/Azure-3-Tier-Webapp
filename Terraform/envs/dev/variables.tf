variable "azure_region" { default = "westeurope" }
variable "env" { default = "usecase3" }
variable "stage" { default = "dev" }
variable "standard_tags" {
  default = { env = var.env, stage = var.stage }
}