#!/bin/bash

## install and upgrade packages
apt update && DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y vim git

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
sed '/PasswordAuthentication/d' -i /etc/ssh/ssh_config
echo  >> /etc/ssh/ssh_config
echo '    PasswordAuthentication no' >> /etc/ssh/ssh_config

# Set Raspberry pi hostname
echo Setup the hostname
if [ $RPI_HOSTNAME ]
then
    echo $RPI_HOSTNAME > /etc/hostname
    echo `echo $RPI_IP_ADDRESS | cut -f1 -d/` $RPI_HOSTNAME >> /etc/hosts
fi

# Configure IP address if $RPI_DHCP_DISABLE is defined
echo Configure network settings
if [ $RPI_DHCP_DISABLE ]
then
    {
        echo "interface $RPI_INTERFACE"
        echo "static ip_address=$RPI_IP_ADDRESS"
        echo "static routers=$RPI_GATEWAY"
        echo "static domain_name_servers=$RPI_DNS_SERVERS"
    } >> /etc/dhcpcd.conf
fi