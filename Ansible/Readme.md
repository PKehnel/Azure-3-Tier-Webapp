# Ansible

This module contains the main Ansible playbook: `playbook.yaml`, which included multiple nested playbooks and the dynmic
inventory file: `inventory_azure_rm.yaml`. There is also a `Vagrantfile` for debugging and running the playbooks local.

## Playbook:

Following tasks are executed when running the playbook:

- update OS
- install Base packages
- create users
- setup webserver (Nginx)
- install telegraf agent for monitoring (cpu, mem, nginx)

The playbook can be run on Debian and RedHat machines.

## Inventory File:

We use a dynamic inventory with the azure module. We group all VMs in a specified resource group by:

- OS (Rhel / Ubuntu) In the playbook we set Ubuntu as host for the webservers
- Tags (env, this is currently disabled, but should be used in the future)

## Notes:

- bug in the telegraf setup (adding nginx pluing missing)
- Env and Dev are currently not distributed to the Ansible user / rg vars, and have to bet set manually in the vars and
  inventory file. 