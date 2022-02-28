# Biceps

Bicep is a domain-specific language (DSL) that uses declarative syntax to deploy Azure resources. 
We use it to generate prerequisite infrastructure for Terraform.
Bicep only deploys services, if they do not already exist. 

## Setup infrastructure
- terraform storage (`provider.tf` backend config), hen egg problem
- azure keyvault for azure credentials