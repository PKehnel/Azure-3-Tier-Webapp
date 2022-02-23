output "virtual_server_private_ip" {
  value = azurerm_network_interface.nic_webservers.*.private_ip_address
}
output "virtual_server_name" {
  value = azurerm_virtual_machine.virtual_servers.*.name
}