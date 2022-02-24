output "vault_name" {
  value = azurerm_key_vault.vault.name
}

output "public_ssh_key_webserver" {
  value = tls_private_key.ssh_key.public_key_openssh
}