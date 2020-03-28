#!/bin/bash

## install and upgrade packages
apt update && apt -yy dist-upgrade
apt install -yy vim git

# use python3
rm -rf /usr/bin/python
ln -s /usr/bin/python3.7 /usr/bin/python

# Enable SSH
# Your public key (~/.ssh/id_rsa) will be added to authorized_keys file
touch /boot/ssh
mkdir /home/pi/.ssh

# Disable password authentication
sed '/PasswordAuthentication/d' -i /etc/ssh/ssh_config
echo  >> /etc/ssh/ssh_config
echo 'PasswordAuthentication no' >> /etc/ssh/ssh_config