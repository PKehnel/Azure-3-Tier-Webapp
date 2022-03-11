# Three Tier Webapp

[![Lint Code Base](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/linter.yml/badge.svg)](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/linter.yml)
[![tfsec-pr-commenter](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/tfsec_pr_commenter.yml/badge.svg)](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/tfsec_pr_commenter.yml)

***Fully automated creation of a 3-Tier-Webapp with Terraform and Ansible on Azure Cloud.***

---

## Infrastructure

![Architecture Overview](Documentation/images/UC3-Architecture.jpg?raw=true "Architecture Overview")

## Documentation

### Basic usage

- pushing to main only from Dev
- go the [dev](Terraform/stage/dev) or [prod](Terraform/stage/prod) environment
- configure the main to your preference or use the standard config matching the above displayed use case
- run terraform commands:
  - `terraform init`
  - `terraform plan`
  - `terraform apply`

- when running the project with remote state file, configure via azure.conf and provider.tf
- for pipeline usage see the [Documentation Folder](/Documentation).

For complete Documentation also see the [Documentation Folder](/Documentation).

