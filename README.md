[![Lint Code Base](https://github.kyndryl.net/Cloud-Germany/UIT-3-Tier-Webapp/actions/workflows/linter.yml/badge.svg)](https://github.kyndryl.net/Cloud-Germany/UIT-3-Tier-Webapp/actions/workflows/linter.yml)
[![tfsec-pr-commenter](https://github.kyndryl.net/Cloud-Germany/UIT-3-Tier-Webapp/actions/workflows/tfsec.yml/badge.svg)](https://github.kyndryl.net/Cloud-Germany/UIT-3-Tier-Webapp/actions/workflows/tfsec.yml)

# uc3
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
 
Terraform Module to provision IaaS  in MS Azure

---

**Infrastructure**

![Archhitecture Overview](Documentation/images/UC3-Architecture.jpg?raw=true "Architecture Overview")

## Documentation

### Basic usage

- go the the [dev](Terraform/envs/dev) or [prod](Terraform/envs/prod) environment 
- configure the main to your preference or use the standard config matching the above displayed usecase
- run terraform commands: 
  - `terraform init` 
  - `terraform plan`
  - `terraform apply`

- when running the project with remote state file, configure via azure.conf and provider.tf
- for pipeline usage see the [Documentation Folder](/Documentation).

For complete Documentation also see the [Documentation Folder](/Documentation).

