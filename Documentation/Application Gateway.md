## Application Gateway vs "Classic" Load Balancer

[Azure Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/overview) is a web traffic load balancer that enables you to manage traffic to your web applications. (OSI Layer 7)

Traditional load balancers operate at the transport layer (OSI layer 4 - TCP and UDP) and route traffic based on source IP address and port, to a destination IP address and port.

**Advantage of Application gateway:** 
- easily integrate WAF
- 80 / 443 ag perfect