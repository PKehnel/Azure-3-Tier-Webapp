#!/bin/bash
#userName="case3-dev-ansible-0-admin"
#userHome="/home/case3-dev-ansible-0-admin"
userHome="/root/"

sudo yum update -y
sudo yum install git -y
sudo yum install python3-pip -y
pip3 install --upgrade pip
pip3 install "ansible==2.9.17"
pip3 install ansible[azure]

sudo mkdir $userHome.azure
sudo cat << EOF | sudo tee $userHome.azure/credentials
[default]
subscription_id=b930202f-9e27-40c2-b275-03609596ad3b
client_id=f1ba5d01-003f-4549-9fe8-2f223bb4ba22
secret=k6H7Q~y2Hpsk2AWjxxY3kYyhw5M4_MaXLQtC_
tenant=e205499b-d99a-415a-9534-683ac582c1c5
EOF

# ssh key
printf "%s" "${ssh_private_key}" | sudo  tee "$userHome.ssh/private_key.pem"
sudo chmod 400 $userHome.ssh/private_key.pem

sudo cat << EOF | sudo tee "$userHome.ssh/config"
Host  *
StrictHostKeyChecking accept-new
EOF

# create config for ansible in home directory to disable warning (otherwise azure pipeline fails)
sudo cat << EOF | sudo tee "$userHome.ansible.cfg"
[defaults]
deprecation_warnings = False
EOF

sudo mkdir /myagent
cd /myagent
sudo wget https://vstsagentpackage.azureedge.net/agent/2.198.3/vsts-agent-linux-x64-2.198.3.tar.gz
sudo tar zxvf vsts-agent-linux-x64-2.198.3.tar.gz
sudo chmod -R 777 /myagent
sudo runuser -l case3-dev-ansible-0-admin -c '/myagent/config.sh --unattended  --url https://dev.azure.com/UIT-DEMO --auth pat --token j7swyc5524upmerojisbuwasodv536pjk26womfmlafywudlfsra --pool Ansible'
sudo /myagent/svc.sh install
sudo /myagent/svc.sh start
exit 0

# #ansible-galaxy collection install azure.azcollection
#pip3 install -r $userHome/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt #todo find location
