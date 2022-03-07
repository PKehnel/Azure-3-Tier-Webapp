# Ansible Host

This module creates a Virtual Server Instance with the possibility to execute a script during startup. The default
scripts setups an Ansible Host. The required azure credentials are passed from an infrastructure key vault. The private
SSH key is created on the fly by the Key Vault module.

### Ansbile Setup:

The ansible script executes following steps:

- install ansible
- create azure credentials
- store private ssh key
- install azure agent

### Localhost vs Hosted:

We decided to use an Ansible host instead of running the playbooks locally. There are some advantages of running the
playbooks local:

- less complexity
- no central point with access to all machines (security)

But for a production environment with multiple stages and a infrastructure layer an Ansible host allows managing all
servers. This is critically for extreme situations like Log4j.


### Notes:

- the current implementation doesn't allow scaling.
