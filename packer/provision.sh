#!/bin/bash

## install and upgrade packages
if $UPDATE_PKGS
then
    apt update && DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y
    DEBIAN_FRONTEND=noninteractive apt install -y vim git
fi
# use python3
echo Setup python3
rm -rf /usr/bin/python
ln -s /usr/bin/python3.7 /usr/bin/python

# Enable SSH
# Your public key (~/.ssh/id_rsa) will be added to authorized_keys file
echo Enable SSH
touch /boot/ssh
mkdir /home/pi/.ssh

# Disable password authentication
echo Disable password authentication
sed 's/#PasswordAuthentication yes/PasswordAuthentication no/g' -i /etc/ssh/sshd_config
sed 's/UsePAM yes/UsePAM no/g' -i /etc/ssh/sshd_config

# Set Raspberry pi hostname
echo Setup the hostname
if [ $RPI_HOSTNAME ]
then
    echo "HOSTNAME: $RPI_HOSTNAME"
    echo $RPI_HOSTNAME > /etc/hostname
    echo `echo $RPI_IP_ADDRESS | cut -f1 -d/` $RPI_HOSTNAME >> /etc/hosts
fi

# Configure IP address if $RPI_DHCP_DISABLE is defined
echo Configure network settings
if [ $RPI_DHCP_DISABLE ]
then
 tee -a /etc/dhcpcd.conf <<EOF
interface $RPI_INTERFACE
  static ip_address=$RPI_IP_ADDRESS
  static routers=$RPI_GATEWAY
  static domain_name_servers=$RPI_DNS_SERVERS
EOF
fi