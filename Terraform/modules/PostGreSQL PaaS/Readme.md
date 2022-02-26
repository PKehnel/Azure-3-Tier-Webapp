# PostGreSQL

PostgreSQL - Flexible Server is a fully managed PostgreSQL database.
Its deployed in the same Vnet as the other services, allowing connecting by using private IP addresses.

Background info: https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/

Networking: https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking


### Notes:

- the subnet has to to use `service_delegation` and is the only subnet that is not created directly in the Vnet Module
- Security groups are in place so only ingress from the Webserver VM's is allowed