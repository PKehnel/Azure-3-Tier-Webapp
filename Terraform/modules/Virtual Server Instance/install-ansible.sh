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

#mkdir ~/.azure
#cat << EOF > ~/.azure/credentials
#[default]
#subscription_id=b930202f-9e27-40c2-b275-03609596ad3b
#client_id=f1ba5d01-003f-4549-9fe8-2f223bb4ba22
#secret=k6H7Q~y2Hpsk2AWjxxY3kYyhw5M4_MaXLQtC_
#tenant=e205499b-d99a-415a-9534-683ac582c1c5
#EOF
#
#
#sudo mkdir /myagent
#cd /myagent
#sudo wget https://vstsagentpackage.azureedge.net/agent/2.198.3/vsts-agent-linux-x64-2.198.3.tar.gz
#sudo tar zxvf vsts-agent-linux-x64-2.198.3.tar.gz
#sudo chmod -R 777 /myagent
#sudo runuser -l case3-dev-ansible-0-admin -c '/myagent/config.sh --unattended  --url https://dev.azure.com/UIT-DEMO --auth pat --token j7swyc5524upmerojisbuwasodv536pjk26womfmlafywudlfsra --pool Ansible'
#sudo /myagent/svc.sh install
#sudo /myagent/svc.sh start
#exit 0