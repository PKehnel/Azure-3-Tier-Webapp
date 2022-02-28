# Azure Key Vault

The Key Vault module stores secrets and certificates for the environment. The permissions are set following the
principle of least privilege. All used credentials are supposed to be created and stored with the module.

### Notes:

- the keyvault name needs to be unique across all azure accounts
- delete and purge are required for "terraform destroy" to work