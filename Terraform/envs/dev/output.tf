output "Application_Gateway_IP_addr" {
  value = module.Application_Gateway.instance_ip_addr
}
output "private_ssh_key" {
  value = module.VSI_Webserver.tls_private_key
  sensitive = true
}