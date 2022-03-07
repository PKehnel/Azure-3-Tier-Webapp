# Webserver-Instanz

Dieses Modul erstellt virtuelle Serverinstanzen in einem "Availability Set". Der öffentliche ansible SSH-Schlüssel wird vom Key 
Vault-Modul empfangen. Passwörter werden generiert und im Schlüsseltresor gespeichert.

### Anmerkungen:

- Die Standardkonfiguration verwendet CIS-gehärtete Ubuntu-Images (18.04 LTS) mit CIS-Automatisierungstools, um eine Sicherheits-Baseline zu etablieren
- SG lässt nur eingehenden Datenverkehr vom Application-Gateway und ausgehenden Datenverkehr zum Datenbankmodul zu
- Protokollierung und Überwachung werden über VM-Erweiterungen aktiviert
