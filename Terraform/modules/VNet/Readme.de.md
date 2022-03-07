# Vnet

Das VNet-Modul erstellt mehrere allgemeine Ressourcen:

- VNet
- Ressourcengruppe am definierten Standort
- LogAnalytics-Arbeitsbereich
- VM INsights Log Analytics-Lösung zum Erfassen zusätzlicher Metriken für VMs
- die meisten Subnetze werden hier erstellt (Ausnahme ist das PostGreSQL-Subnetz)

## Anmerkungen:

- Alle anderen Module hängen von diesem Modul ab
- Dieses Modul verteilt den `resource_group_name` und den `virtual_network_name` an alle Module
- zentrales Modul zum Definieren des Attributs "Standort".