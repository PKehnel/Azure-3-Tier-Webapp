#!/bin/bash
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
subscription_id=${subscription_id}
client_id=${client_id}
secret=${secret}
tenant=${tenant}
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
sudo runuser -l "${userName}" -c '/myagent/config.sh --unattended  --url https://dev.azure.com/UIT-DEMO --auth pat --token ${pat_token} --pool "${naming_prefix}-Ansible" --replace'
sudo /myagent/svc.sh install
sudo /myagent/svc.sh start
exit 0