# PostGreSQL

"PostgreSQL - Flexible Server" ist eine vollständig verwaltete PostgreSQL-Datenbank. Sie wird im selben VNet wie die anderen Dienste bereitgestellt, um so eine Verbindung über private IP-Adressen ermöglichen.

Hintergrundinformationen: https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/

Netzwerk: https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking

### Anmerkungen:

- Das Subnetz muss "service_delegation" verwenden und ist das einzige Subnetz, das nicht direkt im Vnet-Modul erstellt wird
- Es sind Sicherheitsgruppen etabliert, sodass nur Kommunikation von den Webserver-VMs zulässig ist