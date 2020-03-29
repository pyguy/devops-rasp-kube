# Kuberenetes cluster on RaspberryPi the DevOps way

This repo installs [K3S](https://k3s.io) kubernetes cluster on 3 raspberry pi computers. I used recent raspberry pi model (4B) for this demo but you can install it on almost all modern raspberry pi models. (RPi 2,3 and 4)

We'd like to use DevOps/Cloud tools such as `docker`, `packer` and `ansible` to make it cool like we are running the cluster on our own home private cloud ;-) 

## Build the raspberry pi image

We're going to build rapsberry pi images by `packer` using [packer-builder-arm-image](pyguy/packer-builder-arm-image) repo.

### Docker

Clone [packer-builder-arm-image](pyguy/packer-builder-arm-image) repository:

   `git clone github.com/pyguy/packer-builder-arm-image`

Build the docker image:
    
```bash
cd packer-builder-arm-image/

docker build -t packer-builder-arm:latest .
```
Run the docker container to build the raspberry pi image:

```bash
cd packer/

docker run \
  --rm \
  --privileged \
  -v ${PWD}:/build:rw \
  -v ${HOME}/.ssh:/build/.ssh:ro \
  -v ${PWD}/packer_cache:/build/packer_cache \
  -v ${PWD}/output-arm-image:/build/output-arm-image \
  -e RPI_HOSTNAME=raspberrypi.local \
  -e RPI_DHCP_DISABLE=true \
  -e RPI_INTERFACE=eth0 \
  -e RPI_IP_ADDRESS=192.168.1.100/24 \
  -e RPI_GATEWAY=192.168.1.1 \
  -e RPI_DNS_SERVERS=8.8.8.8 \
  packer-builder-arm build raspbian_kube.json
```
The image will be placed on `output-arm-image` directory.

**Notes**: 

* You can use the following custom environment variables in the docker run command:

    |      Env name      |    Env value         | Example          | Required |
    | :----------------- | :------------------- | :--------------- | :------: |
    | `RPI_HOSTNAME`     | hostname             | raspberrypi.local| Yes      |
    | `RPI_DHCP_DISABLE` | true/false           | true             | No       |
    | `RPI_INTERFACE`    | network interface    | eth0             | No       |
    | `RPI_IP_ADDRESS`   | ip address with cidr | 192.168.1.1/24   | No       |
    | `RPI_GATEWAY`      | router gateway       | 192.168.1.1      | No       |
    | `RPI_DNS_SERVERS`  | dns servers          | 8.8.8.8          | No       |

* Your default public key will be added to the image, to add any other custom public keys to the image add the following variable to the following command:
`-var ssh_key_src=<custom public key file>`

## Setup the SD card
 The following section is going to be used for all the nodes in the cluser. So let's do it one by one:

### Flashing the SD card
We use [Etcher](https://www.balena.io/etcher/) for flashing the SD-cards. Just select the image file we built on `output-arm-image/<hostname>.img`, insert your SD-card, select the drive, and click “Flash!”. That's it!

![Etcher](_docs/etcher_screenshot.png)

## Run K3S cluster with ansible

We use ansible roles for setting up the cluster. 

### Make inventory file
Copy the sample inventory file:
 `cp inventory/hosts.ini.sample inventory/hosts.ini`
 
 and make sure that the inventory file is updated with your own hosts.

### setup cluster
Run the following ansible playbook command:
```bash
ansible-plapybook -i inventory/hosts.ini site.yml
```

### delete the cluster
Run the following ansible playbook command:
```bash
ansible-plapybook -i inventory/hosts.ini reset.yml
```