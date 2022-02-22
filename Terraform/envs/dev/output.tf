#output "Application_Gateway_IP_addr" {
#  value = module.Application_Gateway.instance_ip_addr
#}
output "vault_name" {
  value = module.Azure_Key_Vault.vault_name
}

