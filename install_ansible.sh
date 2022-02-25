#! /bin/bash
sudo yum install epel-release -y
sudo yum install ansible -y
sudo yum -y install git
cd /home/centos
git clone https://github.com/bathulaashwini02/ansible.git
chmod 400 ~/Linex8AM.pem
