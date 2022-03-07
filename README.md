[[German](<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 3 2"><path d="M0 0h5v3H0z"/><path fill="#D00" d="M0 1h5v2H0z"/><path fill="#FFCE00" d="M0 2h5v1H0z"/></svg>)](Readme.de.md)
# Use Case 3 Three Tier Webapp

[![Lint Code Base](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/linter.yml/badge.svg)](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/linter.yml)
[![tfsec-pr-commenter](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/tfsec_pr_commenter.yml/badge.svg)](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/tfsec_pr_commenter.yml)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

Terraform Module to provision IaaS in MS Azure

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

