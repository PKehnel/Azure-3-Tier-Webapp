# Use Case 3 Three Tier Webapp

[![Lint Code Base](https://github.kyndryl.net/Cloud-Germany/UIT-3-Tier-Webapp/actions/workflows/linter.yml/badge.svg)](https://github.kyndryl.net/Cloud-Germany/UIT-3-Tier-Webapp/actions/workflows/linter.yml)
[![tfsec-pr-commenter](https://github.kyndryl.net/Cloud-Germany/UIT-3-Tier-Webapp/actions/workflows/tfsec_pr_commenter.yml/badge.svg)](https://github.kyndryl.net/Cloud-Germany/UIT-3-Tier-Webapp/actions/workflows/tfsec_pr_commenter.yml)

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

Terraform Module to provision IaaS in MS Azure

---

## Infrastructure

![Architecture Overview](Documentation/images/UC3-Architecture.jpg?raw=true "Architecture Overview")

## Documentation

### Manual usage:
- go the [dev](Terraform/stage/dev) or [prod](Terraform/stage/prod) environment
- configure the main to your preference or use the standard config matching the above displayed use case
- run terraform commands:
  - `terraform init`
  - `terraform plan`
  - `terraform apply`

### Automation
- when running the project with remote state file, configure via azure.conf and provider.tf
- pipeline can be imported and started directly via Azure Devops
- Run `inital_setup.yml` first to setup TF state file and a keyvault. Add the Service Principal credentials to the keyvault (required for Ansible)
- Next run `build-pipeline.yml` for the Terraform infrastructure and finally `ansible-setup.yml` for the Nginx Setup via Ansible.
- Destroy all with the `destory-pipeline.yml`

For complete Documentation also see the [Documentation Folder](/Documentation). 
Also each module has its own markdown file, containing basic information.

