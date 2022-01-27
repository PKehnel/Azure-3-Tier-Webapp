output "address" {
  description = "Public IP address the website will respond to"
  value = "${azurerm_public_ip.pip_gw.ip_address}"
}

output "mysql_password" {
  description = "Password of the Postgres DB"
  value = "${azurerm_key_vault_secret.mysql_secret.value}"
  sensitive = true
}