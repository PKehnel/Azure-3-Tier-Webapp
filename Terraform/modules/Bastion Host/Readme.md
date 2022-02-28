# Bastion Host

The bastion host allows connecting to the virtual machines via ssh even if they only have private endpoints. It's a full
manged service.

Background info: https://docs.microsoft.com/en-us/azure/bastion/bastion-overview

### Notes:

- the subnet has to be named: `AzureBastionSubnet`