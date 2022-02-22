#!/bin/bash
userName="case3-dev-ansible-0-admin"
userHome="/home/case3-dev-ansible-0-admin"


sleep 60
# Update all packages that have available updates.
sudo yum update -y | tee -a "$userHome/log_ansible"

# Git for agent
sudo -u $userName yum install -y git | tee -a "$userHome/log_ansible" #todo  this failed?

# Install Python 3 and pip.
sudo -u $userName yum install -y python3-pip
#sudo -u $userName yum install @python38

# Upgrade pip3.
pip3 install --upgrade pip

# Install ansible
pip3 install ansible

# Install Ansible az collection for interacting with Azure.
ansible-galaxy collection install azure.azcollection | tee -a "$userHome/log_ansible"

# Install Ansible modules for Azure
sudo -u $userName pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt #todo find location

#sudo -u $userName mkdir ~/.azure # this fails
sudo -u $userName mkdir "$userHome/.azure"

cat << EOF > $userHome/.azure/credentials
[default]
subscription_id=b930202f-9e27-40c2-b275-03609596ad3b
client_id=f1ba5d01-003f-4549-9fe8-2f223bb4ba22
secret=k6H7Q~y2Hpsk2AWjxxY3kYyhw5M4_MaXLQtC_
tenant=e205499b-d99a-415a-9534-683ac582c1c5
EOF

sudo -u $userName mkdir $userHome/.ssh
cat << EOF | sudo -u $userName tee $userHome/.ssh/config
Host  *
StrictHostKeyChecking accept-new
EOF

# ssh key
printf "%s" "${ssh_private_key}" | sudo -u $userName tee "$userHome/.ssh/private-key.pem"
# chmod 400

# create config for ansible in home directory to disable warning (otherwise azure pipeline fails)
cat << EOF | sudo -u $userName tee $userHome/.ansible.cfg
[defaults]
deprecation_warnings = False
EOF

sudo mkdir /myagent
cd /myagent
sudo wget https://vstsagentpackage.azureedge.net/agent/2.198.3/vsts-agent-linux-x64-2.198.3.tar.gz
sudo tar zxvf vsts-agent-linux-x64-2.198.3.tar.gz
sudo chmod -R 777 /myagent
sudo runuser -l $userName -c '/myagent/config.sh --unattended  --url https://dev.azure.com/UIT-DEMO --auth pat --token j7swyc5524upmerojisbuwasodv536pjk26womfmlafywudlfsra --pool Ansible'
sudo /myagent/svc.sh install
sudo /myagent/svc.sh start
exit 0