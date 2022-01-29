# uc3
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
 
Terraform Script to provision an IaaS infrastructure in MS Azure

---

**Infrastructure**

![Archhitecture Overview](Documentation/images/UC3-Architecture.jpg?raw=true "Architecture Overview")

---
**Open Topics:** 

**Iteration 2:** 

- Tagging (Example or do we add it to all?)
- Loops (as show off)
- Output (added a single output for gw ip, what else should we add)
- naming conventions (check all files if we missed names)
- both DB in same Subnet yes / no


- Test and Debug [https://www.hashicorp.com/blog/testing-hashicorp-terraform](https://www.hashicorp.com/blog/testing-hashicorp-terraform)
- Refactor Subnet location (currently in Vnet, wrong position)
- Refactor Variables as top part of each module is currently the same
