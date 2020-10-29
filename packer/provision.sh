#!/bin/bash

# retrieve OS info
DISTRO=$(cat /etc/os-release | awk -F = '/^ID=/{print $2}')
## install and upgrade packages
if $UPDATE_PKGS
then
    apt update && DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y
    DEBIAN_FRONTEND=noninteractive apt install -y vim git
fi
if [ "$DISTRO" == "raspbian" ]
then
  # use python3
  echo Setup python3
  rm -rf /usr/bin/python
  ln -s /usr/bin/python3.7 /usr/bin/python

  # Enable SSH
  echo Enable SSH
  touch /boot/ssh
  # Your public key (~/.ssh/id_rsa) will be added to authorized_keys file
  mkdir /home/pi/.ssh
elif [ "$DISTRO" == "ubuntu" ]
then
  mkdir /home/ubuntu/.ssh
fi

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
if [[ $RPI_DHCP_DISABLE && "$DISTRO" == "raspbian" ]]
then
 tee -a /etc/dhcpcd.conf <<EOF
interface $RPI_INTERFACE
  static ip_address=$RPI_IP_ADDRESS
  static routers=$RPI_GATEWAY
  static domain_name_servers=$RPI_DNS_SERVERS
EOF
elif [[ $RPI_DHCP_DISABLE && "$DISTRO" == "ubuntu" ]]
then
 tee -a /etc/netplan/50-cloud-init.yaml <<EOF
# Generated with packer <https://github.com/pyguy/devops-rasp-kube>
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    $RPI_INTERFACE:
     dhcp4: no
     addresses: [$RPI_IP_ADDRESS]
     gateway4: $RPI_GATEWAY
     nameservers:
       addresses: [$RPI_DNS_SERVERS]
EOF
fi