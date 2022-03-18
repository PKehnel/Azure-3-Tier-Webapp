# Three Tier Webapp

[![Lint Code Base](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/linter.yml/badge.svg)](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/linter.yml)
[![tfsec-pr-commenter](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/tfsec_pr_commenter.yml/badge.svg)](https://github.com/PKehnel/Azure-3-Tier-Webapp/actions/workflows/tfsec_pr_commenter.yml)

---

## Infrastructure

![Architecture Overview](Documentation/images/UC3-Architecture.jpg?raw=true "Architecture Overview")

## Documentation

### Goal
Provision a 3-tier-application with terraform, consisting of a **PostGreSQL** Database, two **nginx** webservers and a **load balancer**. 
Also provide additional infrastructure, including a **keyvault**, and **Ansible** Host and a **Bastion** Host.
Then configure the **Webservers** using **Ansible**. This includes OS updates, OS hardening, creating a user and adding a **Telegraf** agent to collect nginx metrics.

### Manual usage:
- go the [dev](Terraform/stage/dev) or [prod](Terraform/stage/prod) environment
- configure the main to your preference or use the standard config matching the above displayed use case
- run terraform commands:
  - `terraform init`
  - `terraform plan`
  - `terraform apply`
- run ansible playbook: (pass the stage variable matching the stage you chose for step 1)
  - `ansible-playbook playbook.yaml -i inventory_azure_rm.yaml`

### Automation
- when running the project with remote state file, configure via azure.conf and provider.tf
- pipeline can be imported and started directly via Azure Devops
- Run `inital_setup.yml` first to setup TF state file and a keyvault. Add the Service Principal credentials to the keyvault (required for Ansible). Change the keyvault name as it needs to be unique over all azure accounts.
- Next run `build-pipeline.yml` for the Terraform infrastructure and finally `ansible-setup.yml` for the Nginx Setup via Ansible.
- Destroy all with the `destory-pipeline.yml`

For complete Documentation also see the [Documentation Folder](/Documentation). 
Also each module has its own markdown file, containing basic information.

