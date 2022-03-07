# Azure Key Vault

Das Key Vault-Modul speichert Geheimnisse und Zertifikate für die Umgebung. Die Berechtigungen werden im Anschluss an festgelegt
Prinzip der geringsten Privilegien. Alle verwendeten Anmeldeinformationen sollen mit dem Modul erstellt und gespeichert werden.

### Anmerkungen:

- Der Schlüsseltresorname muss für alle Azure-Konten eindeutig sein
- "Delete" und "Purge" Rechte sind erforderlich, damit "Terraform Destroy" funktioniert