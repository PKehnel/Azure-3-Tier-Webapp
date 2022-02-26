# Webserver Instance

This module creates Virtual Server Instances in an Availability Set. 
The public ansible ssh key is received from the Key vault module. 
Password are generated and stored in the keyvault.

### Notes:

- the standard config uses CIS hardened Ubuntu images (18.04 LTS) with CIS automation tooling to establish a security baseline
- SG allow only incoming traffic from the Application gateway and outgoing traffic to the Database module
- logging and monitoring is enabled via VM extensions