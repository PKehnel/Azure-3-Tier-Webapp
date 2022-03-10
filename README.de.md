# Use Case 3 Three Tier Webapp


[![Lint Code Base](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/linter.yml/badge.svg)](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/linter.yml)
[![tfsec-pr-commenter](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/tfsec_pr_commenter.yml/badge.svg)](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/tfsec_pr_commenter.yml)

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

Terraform Module zum Provisionieren einer IaaS in MS Azure

---

## Infrastruktur

![Architecture Overview](Documentation/images/UC3-Architecture.jpg?raw=true "Architecture Overview")

## Dokumentation

### Benutzung

- Pushing zum "main" Branch nur aus Dev
- Wechsele zur [dev](Terraform/stage/dev) oder [prod](Terraform/stage/prod) Umgebung
- Konfiguriere den "main" Branch basierend auf den konkreten Anforderungen oder benutze diese Config, um den oben abgebildeten UseCase zu provisionieren
- Führe die Terraform Kommandos aus:
  - `terraform init`
  - `terraform plan`
  - `terraform apply`

- Um das Projekt mit einem remote TF statefile zu benutzen, so ist dies via azure.conf und provider.tf zu konfigurieren
- Die Benutzung in einer Pipeline ist im [Documentation Folder](/Documentation) Folder beschrieben.

Die komplette Dokumentation ist ebenfalls im [Documentation Folder](/Documentation) Folder beinhaltet.

