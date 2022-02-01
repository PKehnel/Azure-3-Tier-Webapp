# uc3
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
 
Terraform Script to provision an IaaS infrastructure in MS Azure

---

**Infrastructure**

![Archhitecture Overview](Documentation/images/UC3-Architecture.jpg?raw=true "Architecture Overview")

---
**Open Topics:**
- auswahl betriebsystem 
- Kusto Queries zur Logauswertung (2-3)

**On Hold**
- Tagging (Example or do we add it to all?) (Policy tagging)
- naming conventions (check all files if we missed names)
- Test and Debug [https://www.hashicorp.com/blog/testing-hashicorp-terraform](https://www.hashicorp.com/blog/testing-hashicorp-terraform)


## Application Gateway vs "Classic" Load Balancer

[Azure Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/overview) is a web traffic load balancer that enables you to manage traffic to your web applications. (OSI Layer 7)

Traditional load balancers operate at the transport layer (OSI layer 4 - TCP and UDP) and route traffic based on source IP address and port, to a destination IP address and port.

Advantage of Application gateway: 
- easily integrate WAF
- 80 / 443 ag perfect