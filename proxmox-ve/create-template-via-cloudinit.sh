#!/bin/bash
set -o errexit

apt-get update 
apt-get -y upgrade
apt-get -y dist-upgrade

printf "\n*** Packages updated ***\n\n"
sleep 5

clear
printf "\n*** This script will download a cloud image and create a Proxmox VM template from it. ***\n\n"

### Prerequisites:
### - create-template-via-cloudinit.sh should be executed on a Proxmox VE 6.x Server.
### - A DHCP Server should be active on vmbr0
### - Download Latest Version of the Script:
###   curl https://raw.githubusercontent.com/BarisGece/mHC/main/proxmox-ve/create-template-via-cloudinit.sh > /usr/local/bin/create-template-via-cloudinit.sh && chmod -v +x /usr/local/bin/create-template-via-cloudinit.sh
### - (optionally) Prepare a cloudinit user-config.yml in the working directory. For more information https://cloudinit.readthedocs.io/en/latest/topics/examples.html#yaml-examples.
###   This could be copied and modified from the cloudinit user dump at the end of this script.
### - Run the Script:
###   $ create-template-via-cloudinit.sh
### - Clone the Finished Template from the Proxmox GUI and Test
###
### NOTES:
### - Links to Cloud Images:
###   Directory             : https://docs.openstack.org/image-guide/obtain-images.html
###   Debian                : http://cdimage.debian.org/cdimage/cloud/OpenStack/
###   Ubuntu                : http://cloud-images.ubuntu.com/
###   RancherOS             : https://github.com/rancher/os/releases (Also includes Proxmox iso version)
###   Flatcar (CoreOS fork) : https://stable.release.flatcar-linux.net/amd64-usr/?sort=time&order=desc - https://www.flatcar-linux.org/
###   CentOS                : https://cloud.centos.org/centos/
###   Arch (also Gentoo)    : https://linuximages.de/openstack/arch/
###   Fedora                : https://alt.fedoraproject.org/cloud/
###   Gentoo                : http://gentoo.osuosl.org/experimental/amd64/openstack
###   SUSE 15 SP1 JeOS      : https://download.suse.com/Download?buildid=OE-3enq3uys~
###   CirrOS                : http://download.cirros-cloud.net/

## TODO
### - verify authenticity of downloaded images using hash or GPG

printf "* Available templates to generate:\n 2) Debian 9\n 3) Debian 10\n 4) Ubuntu 18.04\n 5) Ubuntu 20.04\n 6) RancherOS 1.5.5\n 7) CoreOS/Flatcar\n 8) Centos 7\n 9) Arch\n\n"
read -p "* Enter number of distro to use: " OSNR
read -p "* Enter Proxmox VE Node Name: " NNAME

# defaults which are used for most templates
RESIZE=+30G
MEMORY=2048
BRIDGE=vmbr0
NODENAME=$NNAME
USERCONFIG_DEFAULT=none # cloud-init-config.yml
CITYPE=nocloud
SNIPPETSPATH=/var/lib/vz/snippets
SSHKEY=~/.ssh/id_rsa.pub
NOTE=""

case $OSNR in

  2)
    OSNAME=debian9
    VMID_DEFAULT=51000
    read -p "Enter a VM ID for $OSNAME [$VMID_DEFAULT]: " VMID
    VMID=${VMID:-$VMID_DEFAULT}
    VMIMAGE_DEFAULT=debian-9-openstack-amd64.qcow2
    read -p "Enter a VM IMAGE NAME for $OSNAME [Click enter to use default image: $VMIMAGE_DEFAULT]: " VMIMAGE
    VMIMAGE=${VMIMAGE:-$VMIMAGE_DEFAULT}
    NOTE="\n## Default user is 'debian'\n## NOTE: Setting a password via cloud-config does not work.\n"
    printf "$NOTE\n"
    wget -P /tmp -N https://cdimage.debian.org/cdimage/openstack/current-9/$VMIMAGE
    ;;

  3)
    OSNAME=debian10
    VMID_DEFAULT=51100
    read -p "Enter a VM ID for $OSNAME [$VMID_DEFAULT]: " VMID
    VMID=${VMID:-$VMID_DEFAULT}
    VMIMAGE_DEFAULT=debian-10-openstack-amd64.qcow2
    read -p "Enter a VM IMAGE NAME for $OSNAME [Click enter to use default image: $VMIMAGE_DEFAULT]: " VMIMAGE
    VMIMAGE=${VMIMAGE:-$VMIMAGE_DEFAULT}
    NOTE="\n## Default user is 'debian'\n"
    printf "$NOTE\n"
    wget -P /tmp -N https://cdimage.debian.org/cdimage/openstack/current-10/$VMIMAGE
    ;;

  4)
    OSNAME=ubuntu1804
    VMID_DEFAULT=52000
    read -p "Enter a VM ID for $OSNAME [$VMID_DEFAULT]: " VMID
    VMID=${VMID:-$VMID_DEFAULT}
    VMIMAGE_DEFAULT=bionic-server-cloudimg-amd64.img
    read -p "Enter a VM IMAGE NAME for $OSNAME [Click enter to use default image: $VMIMAGE_DEFAULT]: " VMIMAGE
    VMIMAGE=${VMIMAGE:-$VMIMAGE_DEFAULT}
    NOTE="\n## Default user is 'ubuntu'\n"
    printf "$NOTE\n"
    wget -P /tmp -N https://cloud-images.ubuntu.com/bionic/current/$VMIMAGE
    ;;

  5)
    OSNAME=ubuntu2004
    VMID_DEFAULT=52100
    read -p "Enter a VM ID for $OSNAME [$VMID_DEFAULT]: " VMID
    VMID=${VMID:-$VMID_DEFAULT}
    VMIMAGE_DEFAULT=focal-server-cloudimg-amd64.img
    read -p "Enter a VM IMAGE NAME for $OSNAME [Click enter to use default image: $VMIMAGE_DEFAULT]: " VMIMAGE
    VMIMAGE=${VMIMAGE:-$VMIMAGE_DEFAULT}
    NOTE="\n## Default user is 'ubuntu'\n"
    printf "$NOTE\n"
    wget -P /tmp -N https://cloud-images.ubuntu.com/focal/current/$VMIMAGE
    ;;

  6)
    OSNAME=rancheros
    VMID_DEFAULT=53000
    read -p "Enter a VM ID for $OSNAME [$VMID_DEFAULT]: " VMID
    VMID=${VMID:-$VMID_DEFAULT}
    VMIMAGE_DEFAULT=rancheros-openstack.img
    VMIMAGE_VERSION_DEFAULT=v1.5.6
    read -p "Enter a VM IMAGE VERSION for $OSNAME [Click enter to use default version: $VMIMAGE_VERSION_DEFAULT]: " VMIMAGE_VERSION
    read -p "Enter a VM IMAGE NAME for $OSNAME [Click enter to use default image: $VMIMAGE_DEFAULT]: " VMIMAGE
    VMIMAGE_VERSION=${VMIMAGE_VERSION:-$VMIMAGE_VERSION_DEFAULT}
    VMIMAGE=${VMIMAGE:-$VMIMAGE_DEFAULT}
    CITYPE=configdrive2
    NOTE="\n## Default user is 'rancher'\n## NOTE: Setting a password via cloud-config does not work.\n#  RancherOS does autologin on console.\n"
    printf "$NOTE\n"
    wget -P /tmp -N https://github.com/rancher/os/releases/download/$VMIMAGE_VERSION/$VMIMAGE
    ;;

  7)
    OSNAME=flatcar
    VMID_DEFAULT=54000
    read -p "Enter a VM ID for $OSNAME [$VMID_DEFAULT]: " VMID
    VMID=${VMID:-$VMID_DEFAULT}
    RESIZE=+24G
    VMIMAGE_DEFAULT=flatcar_production_qemu_image.img.bz2
    VMIMAGE_VERSION_DEFAULT=2605.7.0
    read -p "Enter a VM IMAGE VERSION for $OSNAME [Click enter to use default version: $VMIMAGE_VERSION_DEFAULT]: " VMIMAGE_VERSION
    read -p "Enter a VM IMAGE NAME for $OSNAME [Click enter to use default image: $VMIMAGE_DEFAULT]: " VMIMAGE
    VMIMAGE_VERSION=${VMIMAGE_VERSION:-$VMIMAGE_VERSION_DEFAULT}
    VMIMAGE=${VMIMAGE:-$VMIMAGE_DEFAULT}
    CITYPE=configdrive2
    NOTE="\n## Default user is 'coreos'\n## NOTE: Setting a password via cloud-config does not work.\n"
    printf "$NOTE\n"
    wget -P /tmp -N https://stable.release.flatcar-linux.net/amd64-usr/$VMIMAGE_VERSION/$VMIMAGE
    ;;

  8)
    OSNAME=centos7
    VMID_DEFAULT=56000
    read -p "Enter a VM ID for $OSNAME [$VMID_DEFAULT]: " VMID
    VMID=${VMID:-$VMID_DEFAULT}
    RESIZE=+24G
    VMIMAGE_DEFAULT=CentOS-7-x86_64-GenericCloud.qcow2
    read -p "Enter a VM IMAGE NAME for $OSNAME [Click enter to use default image: $VMIMAGE_DEFAULT]: " VMIMAGE
    VMIMAGE=${VMIMAGE:-$VMIMAGE_DEFAULT}
    NOTE="\n## Default user is 'centos'\n## NOTE: CentOS ignores hostname config.\n#  use 'hostnamectl set-hostname centos7-cloud' inside VM\n"
    printf "$NOTE\n"
    wget -P /tmp -N http://cloud.centos.org/centos/7/images/$VMIMAGE
    ;;

  9)
    OSNAME=arch
    VMID_DEFAULT=57000
    read -p "Enter a VM ID for $OSNAME [$VMID_DEFAULT]: " VMID
    VMID=${VMID:-$VMID_DEFAULT}
    RESIZE=+29G
    VMIMAGE=arch-openstack-LATEST-image-bootstrap.qcow2
    NOTE="\n## Default user is 'arch'\n## NOTE: Setting a password via cloud-config does not work.\n#  Resizing does not happen automatically inside the VM\n"
    printf "$NOTE\n"
    wget -P /tmp -N https://linuximages.de/openstack/arch/$VMIMAGE
    ;;

  *)
    printf "\n** Unknown OS number. Please use one of the above!\n"
    exit 0
    ;;
esac

[[ $VMIMAGE == *".bz2" ]] \
    && printf "\n** Uncompressing image (waiting to complete...)\n" \
    && bzip2 -d --force /tmp/$VMIMAGE \
    && VMIMAGE=$(echo "${VMIMAGE%.*}") # remove .bz2 file extension from file name

# TODO: could prompt for the VM name
printf "\n** Creating a VM with $MEMORY MB using network bridge $BRIDGE\n"
qm create $VMID --name $OSNAME-cloud --memory $MEMORY --net0 virtio,bridge=$BRIDGE

printf "\n** Importing the disk in qcow2 format (as 'Unused Disk 0')\n"
qm importdisk $VMID /tmp/$VMIMAGE local -format qcow2

printf "\n** Attaching the disk to the vm using VirtIO SCSI\n"
qm set $VMID --scsihw virtio-scsi-pci --scsi0 /var/lib/vz/images/$VMID/vm-$VMID-disk-0.qcow2

printf "\n** Setting boot and display settings with serial console\n"
qm set $VMID --boot c --bootdisk scsi0 --serial0 socket --vga serial0

printf "\n** Using a dhcp server on $BRIDGE (or change to static IP)\n"
qm set $VMID --ipconfig0 ip=dhcp
#This would work in a bridged setup, but a routed setup requires a route to be added in the guest
#qm set $VMID --ipconfig0 ip=10.10.10.222/24,gw=10.10.10.1

printf "\n** Creating a cloudinit drive managed by Proxmox\n"
qm set $VMID --ide2 local:cloudinit

printf "\n** Set CPU type\n"
qm set $VMID --cpu host

printf "\n** Enable agent and autostart with os type\n"
qm set $VMID --agent enabled=1 --autostart --onboot 1 --ostype l26

printf "\n** Specifying the cloud-init configuration format\n"
qm set $VMID --citype $CITYPE


## TODO: Also ask for a network configuration. Or create a config with routing for a static IP
printf "\n*** The script can add a cloud-init configuration with users and SSH keys from a file in the current directory.\n"
read -p "Supply the name of the cloud-init-config.yml (this will be skipped, if file not found) [$USERCONFIG_DEFAULT]: " USERCONFIG
USERCONFIG=${USERCONFIG:-$USERCONFIG_DEFAULT}
if [ -f $PWD/$USERCONFIG ]
then
    # The cloud-init user config file overrides the user settings done elsewhere
    printf "\n** Adding user configuration\n"
    cp -v $PWD/$USERCONFIG $SNIPPETSPATH/$VMID-$OSNAME-$USERCONFIG
    qm set $VMID --cicustom "user=local:snippets/$VMID-$OSNAME-$USERCONFIG"
    printf "#* cloud-config: $VMID-$OSNAME-$USERCONFIG\n" >> /etc/pve/nodes/$NODENAME/qemu-server/$VMID.conf
else
    # The SSH key should be supplied either in the cloud-init config file or here
    printf "\n** Skipping config file, as none was found\n\n** Adding SSH key\n"
    qm set $VMID --sshkey $SSHKEY
    printf "\n"
    read -p "Supply an optional password for the default user (press Enter for none): " PASSWORD
    [ ! -z "$PASSWORD" ] \
        && printf "\n** Adding the password to the config\n" \
        && qm set $VMID --cipassword $PASSWORD \
        && printf "#* a password has been set for the default user\n" >> /etc/pve/nodes/$NODENAME/qemu-server/$VMID.conf
    printf "#- cloud-config used: via Proxmox\n" >> /etc/pve/nodes/$NODENAME/qemu-server/$VMID.conf
fi

# The NOTE is added to the Summary section of the VM (TODO there seems to be no 'qm' command for this)
printf "#$NOTE\n" >> /etc/pve/nodes/$NODENAME/qemu-server/$VMID.conf

printf "\n** Increasing the disk size\n"
qm resize $VMID scsi0 $RESIZE

printf "\n** add proxmox.node pub.key to image\n"
qm set $VMID --sshkey ~/.ssh/id_rsa.pub

printf "\n*** The following cloud-init configuration will be used ***\n"
printf "\n-------------  User ------------------\n"
qm cloudinit dump $VMID user
printf "\n-------------  Network ---------------\n"
qm cloudinit dump $VMID network

# convert the vm into a template (TODO make this optional)
qm template $VMID

printf "\n** Removing previously downloaded image file\n\n"
rm -v /tmp/$VMIMAGE

printf "$NOTE\n\n"