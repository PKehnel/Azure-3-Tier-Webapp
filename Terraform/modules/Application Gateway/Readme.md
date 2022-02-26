#Application Gateway
The Application Gateway is placed in front of the webservers and distributes the webtraffic.

The binding happens in the resource: `azurerm_network_interface_application_gateway_backend_address_pool_association`


### Application Gateway vs "Classic" Load Balancer

[Azure Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/overview) is a web traffic load balancer that enables you to manage traffic to your web applications. (OSI Layer 7)

Traditional load balancers operate at the transport layer (OSI layer 4 - TCP and UDP) and route traffic based on source IP address and port, to a destination IP address and port.

**Advantage of Application gateway:** 
- easily integrate WAF
- 80 / 443 ag perfect

###Localhost vs Hosted:

We decided to use an Ansible host instead of running the playbooks locally. 
There are some advantages of running the playbooks local:
 - less complexity
 - no central point with access to all machines (security)
 
But for a production environment with multiple stages and a infrastructure layer an Ansible host allows managing 
all servers. This is critically for extreme situations like Log4j. 

### Notes:

 - the current implementation doesn't allow scaling.
 - as for all infrastructure keys are generated and stored with the Keyvault module 
