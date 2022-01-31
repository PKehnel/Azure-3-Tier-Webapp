output "instance_ip_addr" {
  value = azurerm_public_ip.pip_gw.ip_address
  description = "The private IP address of the Application Gateway."
}