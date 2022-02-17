#!/bin/bash
# Update all packages that have available updates.
sudo yum update -y

# Git for agent
sudo yum install git -y
# Install Python 3 and pip.
sudo yum install -y python3-pip
#sudo yum install @python38

# Upgrade pip3.
pip3 install --upgrade pip

# Install ansible
pip3 install ansible

# Install Ansible az collection for interacting with Azure.
ansible-galaxy collection install azure.azcollection

# Install Ansible modules for Azure
sudo pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt