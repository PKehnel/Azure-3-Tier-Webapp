# Anwendungsgateway

Das Application Gateway wird den Webservern vorgeschaltet und verteilt den Webtraffic.

Die Bindung erfolgt in der Ressource: „azurerm_network_interface_application_gateway_backend_address_pool_association“.

### Application Gateway im Vergleich zum "klassischen" Load Balancer

[Azure Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/overview) ist eine Webtraffic-LoadBalancer, mit dem man den Datenverkehr auf Webanwendungen verwalten kann. (OSI-Schicht 7)

Herkömmliche Load Balancer arbeiten auf der Transportschicht (OSI-Schicht 4 – TCP und UDP) und leiten den Datenverkehr basierend auf der Quelle, IP-Adresse und Port zu einer Ziel-IP-Adresse und einem Port weiter.

**Vorteil des Anwendungsgateways:**

- WAF einfach integrieren
- 80 / 443 perfekt
- SSL Offload
