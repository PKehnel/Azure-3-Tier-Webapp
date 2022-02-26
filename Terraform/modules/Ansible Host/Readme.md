#Ansible Host
This module creates a Virtual Server Instance with the possibility to execute a script during startup.
The default scripts setups an Ansible Host. The required azure credentials are passed from an infrastructure key vault. 
The private SSH key is created on the fly by the Key Vault module.

### Ansbile Setup:
The ansible script executes following steps: 

- install ansible
- create azure credentials 
- store private ssh key
- install azure agent 

### Notes:

- the current implementation doesn't allow scaling.
