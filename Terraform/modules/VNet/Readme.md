# Vnet

The vnet module creates multiple general resources:

- Vnet
- Resource group in the defined location
- LogAnalytics Workspace
- VM INsights Log Analytics Solution to collect additional metrics for VMs
- most subnets are created here (exception is the PostGreSQL subnet)

## Notes:

- all other modules depend on this module
- this module distributes the `resource_group_name` and `virtual_network_name` to all modules
- central module to define the `location` attribute