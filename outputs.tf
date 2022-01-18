output "address" {
  value = "${azurerm_public_ip.pip_lb.ip_address}"
}
