# Ansible

Dieses Modul enthält das Haupt-Ansible-Playbook: „playbook.yaml“, das mehrere verschachtelte Playbooks und die dynamic
Bestandsdatei: „inventory_azure_rm.yaml“. Es gibt auch ein `Vagrantfile` zum Debuggen und lokalen Ausführen der Playbooks.

## Playbook:

Folgende Aufgaben werden beim Ausführen des Playbooks ausgeführt:

- Betriebssystem aktualisieren
- Basispakete installieren
- Benutzer erstellen
- Webserver einrichten (Nginx)
- Telegraf-Agent zur Überwachung installieren (CPU, Mem, Nginx)

Das Playbook kann auf Debian- und RedHat-Rechnern ausgeführt werden.

## Inventardatei:

Wir verwenden ein dynamisches Inventar mit dem Azure-Modul. Wir gruppieren alle VMs in einer bestimmten Ressourcengruppe nach:

- OS (Rhel / Ubuntu) Im Playbook haben wir Ubuntu als Host für die Webserver eingestellt
- Tags (env, dies ist derzeit deaktiviert, sollte aber in Zukunft verwendet werden)

## Anmerkungen:

- Fehler im Telegraf-Setup (Hinzufügen von nginx-Pluing fehlt)
- Env und Dev werden derzeit nicht an die Ansible user / rg vars verteilt und müssen manuell in den vars und inventory Dateien gesetzt werden.