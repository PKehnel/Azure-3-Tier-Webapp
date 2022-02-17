# Setup ansible host

## Azure Credentials

Adjust according to your service principal (also don`t push your secret)
```
export AZURE_SUBSCRIPTION_ID= Your Subscription
export AZURE_CLIENT_ID= Your ID
export AZURE_SECRET= Your Secret
export AZURE_TENANT= Your Tenant
```

or via: 

```
mkdir ~/.azure
cat << EOF > ~/.azure/credentials
[default]
subscription_id= subs
client_id=id
secret=Your Secret
tenant= tenant
EOF
```

add private key

set: owner can read, can't write and can't execute

`chmod 400 .ssh/private_key.pem`


## Ansible Setup Script

````
cat << EOF > ~/ansible_setup.sh
#!/bin/bash

sudo yum install @python3

# Update all packages that have available updates.
sudo yum update -y

# Install Python 3 and pip.
sudo yum install -y python3-pip

# Upgrade pip3.
sudo pip3 install --upgrade pip

# Install Ansible az collection for interacting with Azure.
ansible-galaxy collection install azure.azcollection

# Install Ansible modules for Azure
sudo pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt
EOF
````

## Ansible Dynamic Inventory
```
cat << EOF > myazure_rm.yml
plugin: azure.azcollection.azure_rm
include_vm_resource_groups:
  - case3-dev-rg
auth_source: auto
conditional_groups:
  RedHat: "'RHEL' in image.offer"
  Ubuntu: "'UbuntuServer' in image.offer"
keyed_groups:
 - key: tags.environment
EOF
```

Test via: 

`ansible-inventory -i myazure_rm.yml --graph`


## Basic playbooks running against all Ubuntu Servers

```
cat << EOF > install_basics.yml
---
- hosts: Ubuntu
  gather_facts: false

  vars:
    ansible_user: "case3-dev-webserver-0-admin"
    ansible_ssh_private_key_file: ~/.ssh/private_key.pem

  tasks:
    - name: Install Base packages on Ubuntu
      apt:
        name:
          - git
          - tmux
          - tree
          - vim
        state: present
        update_cache: yes
      become: yes 
EOF
```

### Test Ping all Ubuntu Servers:

```
cat << EOF > ping.yml
---
- hosts: Ubuntu
  gather_facts: false

  vars:
    ansible_user: "case3-dev-webserver-0-admin"
    ansible_ssh_private_key_file: ~/.ssh/private_key.pem

  tasks:
    - name: run ping
      ping:
EOF
```