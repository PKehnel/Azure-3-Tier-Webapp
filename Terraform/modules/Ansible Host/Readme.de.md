# Ansible-Host

Dieses Modul erstellt eine virtuelle Serverinstanz mit der Möglichkeit, beim Start ein Skript auszuführen. Das Standard
Skript richtet einen Ansible Host ein. Die erforderlichen Azure-Anmeldeinformationen werden von einem Infrastrukturschlüsseltresor übergeben. Der private SSH-Schlüssel wird im laufenden Betrieb vom Key Vault-Modul erstellt.

### Ansbile-Setup:

Das Ansible-Skript führt die folgenden Schritte aus:

- Ansible installieren
- Erstellen Sie Azure-Anmeldeinformationen
- privaten SSH-Schlüssel speichern
- Azure-Agent installieren

### Anmerkungen:

- Die aktuelle Implementierung erlaubt keine Skalierung.