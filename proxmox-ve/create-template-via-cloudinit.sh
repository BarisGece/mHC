#!/bin/bash
set -o errexit

printf "\n*** Packages will be updated ***\n\n"
apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade

printf "\n*** Packages Updated. Proxmox VM Template creation will start after 5 seconds ***\n\n"
sleep 5

clear
printf "\n*** This script will download a cloud image and create a Proxmox VM template from it. ***\n\n"

printf "\n*** Do you wish to execute script on Proxmox-VE? ***\n\n"
select yn in "Yes" "No"; do
  case $yn in
    Yes ) break;;
    No ) exit;;
  esac
done

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

printf "\nAvailable templates to generate:\n 2) Debian 9\n 3) Debian 10\n 4) Ubuntu 18.04\n 5) Ubuntu 20.04\n 6) RancherOS 1.5.5\n 7) CoreOS/Flatcar\n 8) Centos 7\n 9) Arch\n\n"
read -p "Enter number of distro to use: " OSNR
read -p "Enter Proxmox VE Node Name: " NNAME

# defaults which are used for most templates
KVM=1
NUMA=1
HOTPLUG=disk,network,usb,cpu,memory 
CPUTYPE=host
CORES=2
SOCKETS=1
vCPUs=2
MEMORY=2048
BRIDGE=vmbr0
FIREWALL=0
AUTOSTART=1
ONBOOT=1
OSTYPE=l26
DISKCACHE=none
CITYPE=nocloud
RESIZE=+30G
NODENAME=$NNAME
SNIPPETSPATH=/snippets/snippets
USERCONFIG_DEFAULT=sample-cloud-init-config.yml
SSHKEY_DEFAULT_CLIENT_NAME=client-id_rsa # DO NOT USE ~/.ssh/id_rsa.pub
NOTE=""

printf "\n*** SSH Keys will be generated to connect Proxmox/Client to VM via SSH ***\n\n"
read -p "Enter a SSH KEY Name for Clients [Click enter to use default ssh client name: $SSHKEY_DEFAULT_CLIENT_NAME]: " SSHKEY_CLIENT_NAME
SSHKEY_CLIENT_NAME=${SSHKEY_CLIENT_NAME:-$SSHKEY_DEFAULT_CLIENT_NAME}
SSHKEY_CLIENT=~/.ssh/$SSHKEY_CLIENT_NAME.pub
if [[ ! -f $SSHKEY_CLIENT ]] ; then
  ssh-keygen -f ~/.ssh/$SSHKEY_CLIENT_NAME -t rsa -b 4096 -C "Client@VM"
  #ssh-keygen -f ~/.ssh/$SSHKEY_CLIENT_NAME -t rsa -b 4096 -P client -C "Client@VM"
  printf "\n** $SSHKEY_CLIENT generated **\n\n"
else
  printf "\n** $SSHKEY_CLIENT IS EXISTS **\n\n"
fi

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
    printf "\n** Unknown OS number. Please use one of the above! **\n"
    exit 0
    ;;
esac

[[ $VMIMAGE == *".bz2" ]] \
    && printf "\n** Uncompressing image (waiting to complete...) **\n" \
    && bzip2 -d --force /tmp/$VMIMAGE \
    && VMIMAGE=$(echo "${VMIMAGE%.*}") # remove .bz2 file extension from file name

# TODO: could prompt for the VM name
echo -e \
      "  \033[2;32m** Creating a VM with **\033[0m\n" \
      "  \033[1;2;34mVMID :\033[0m \033[1;33m$VMID\033[0m\n" \
      "  \033[1;2;34mVM Name :\033[0m \033[1;33m$OSNAME-cloud-template\033[0m\n" \
      "  \033[1;2;34mKVM Enabled :\033[0m \033[1;33m$KVM\033[0m\n" \
      "  \033[1;2;34mNUMA Enabled :\033[0m \033[1;33m$NUMA\033[0m\n" \
      "  \033[1;2;34mHOTPLUG :\033[0m \033[1;33m$HOTPLUG\033[0m\n" \
      "  \033[1;2;34mCPU Type :\033[0m \033[1;33m$CPUTYPE\033[0m\n" \
      "  \033[1;2;34mCPU Cores :\033[0m \033[1;33m$CORES\033[0m\n" \
      "  \033[1;2;34mCPU Sockets :\033[0m \033[1;33m$SOCKETS\033[0m\n" \
      "  \033[1;2;34mHotplugged vCPUs :\033[0m \033[1;33m$vCPUs\033[0m\n" \
      "  \033[1;2;34mMEMORY :\033[0m \033[1;33m$MEMORY\033[0m\n" \
      "  \033[1;2;34mNetwork :\033[0m \033[1;33mBRIDGE=$BRIDGE & FIREWALL=$FIREWALL\033[0m\n" \
      "  \033[1;2;34mQemu Guest Agent :\033[0m \033[1;33menabled=1 & type=virtio\033[0m\n" \
      "  \033[1;2;34mAuto Start :\033[0m \033[1;33mRestart After Crash=$AUTOSTART\033[0m\n" \
      "  \033[1;2;34mOn Boot :\033[0m \033[1;33mVM will be started during system bootup=$ONBOOT\033[0m\n" \
      "  \033[1;2;34mGuest OS :\033[0m \033[1;33m$OSTYPE\033[0m\n" \
      "  \033[2;32m \033[0m\n" \
      "  \033[2;34m \033[0m\n" \
      "  \033[1;33m \033[0m\n"

qm create $VMID --name $OSNAME-cloud-template --kvm $KVM --numa $NUMA --hotplug $HOTPLUG --cpu $CPUTYPE --cores $CORES --sockets $SOCKETS --vcpus $vCPUs --memory $MEMORY --net0 virtio,bridge=$BRIDGE,firewall=$FIREWALL --agent enabled=1,fstrim_cloned_disks=1,type=virtio --autostart $AUTOSTART --onboot $ONBOOT --ostype $OSTYPE

printf "\n** \033[1;33mImporting the disk in raw format (as 'Unused Disk 0')\033[0m **\n"
qm importdisk $VMID /tmp/$VMIMAGE local-lvm --format raw # --format qcow2

printf "\n** \033[1;33mAttaching the disk to the VM using VirtIO SCSI Single\033[0m **\n"
qm set $VMID --scsihw virtio-scsi-single --scsi0 local-lvm:vm-$VMID-disk-0,cache=$DISKCACHE,iothread=1

printf "\n** \033[1;32mCreating a cloudinit drive managed by Proxmox\033[0m **\n"
qm set $VMID --ide2 local-lvm:cloudinit

printf "\n** \033[1;32mSpecifying the cloud-init configuration format\033[0m **\n"
qm set $VMID --citype $CITYPE

printf "\n** \033[1;33mSetting boot and display settings with serial console\033[0m **\n"
qm set $VMID --boot c --bootdisk scsi0 --serial0 socket --vga serial0

printf "\n** \033[1;33mUsing a dhcp server on $BRIDGE (or change to static IP)\033[0m **\n"
qm set $VMID --ipconfig0 ip=dhcp
#This would work in a bridged setup, but a routed setup requires a route to be added in the guest
#qm set $VMID --ipconfig0 ip=10.10.10.222/24,gw=10.10.10.1

## TODO: Also ask for a network configuration. Or create a config with routing for a static IP
printf "\n*** The script can add a cloud-init configuration with users and SSH keys from a file in the current directory. ***\n"
read -p "Supply the name of the cloud-init-config.yml (this will be skipped, if file not found) [$USERCONFIG_DEFAULT]: " USERCONFIG
USERCONFIG=${USERCONFIG:-$USERCONFIG_DEFAULT}
if [[ -f $PWD/$USERCONFIG ]]
then
    # The cloud-init user config file overrides the user settings done elsewhere
    printf "\n** \033[1;32mAdding user configuration\033[0m **\n"
    cp -v $PWD/$USERCONFIG $SNIPPETSPATH/$VMID-$OSNAME-$USERCONFIG
    qm set $VMID --cicustom "user=snippets:snippets/$VMID-$OSNAME-$USERCONFIG"
    printf "# cloud-config: $VMID-$OSNAME-$USERCONFIG\n" >> /etc/pve/nodes/$NODENAME/qemu-server/$VMID.conf
else
    # The SSH key should be supplied either in the cloud-init config file or here
    printf "\n** \033[1;32mSkipping config file, as none was found\033[0m\n\n** Adding SSH key **\n"
    qm set $VMID --sshkey $SSHKEY_CLIENT
    printf "\n"
    read -s -p "Supply an optional password for the default user (press Enter for none): " PASSWORD
    [[ ! -z "$PASSWORD" ]] \
        && printf "\n** Adding the password to the config **\n" \
        && qm set $VMID --cipassword $PASSWORD \
        && printf "# A password has been set for the default user\n" >> /etc/pve/nodes/$NODENAME/qemu-server/$VMID.conf
    printf "# cloud-config used: via Proxmox\n" >> /etc/pve/nodes/$NODENAME/qemu-server/$VMID.conf
fi

# The NOTE is added to the Summary section of the VM (TODO there seems to be no 'qm' command for this)
printf "#$NOTE\n" >> /etc/pve/nodes/$NODENAME/qemu-server/$VMID.conf

printf "\n** \033[1;33mIncreasing the disk size\033[0m **\n"
qm resize $VMID scsi0 $RESIZE

printf "\n*** The following cloud-init configuration will be used ***\n"
if [[ -f $PWD/$USERCONFIG ]]
then
  cat $PWD/$USERCONFIG
else
  printf "\n-------------  User ------------------\n"
  qm cloudinit dump $VMID user
  printf "\n-------------  Network ---------------\n"
  qm cloudinit dump $VMID network
fi

printf "\n\033[1;33m-------------  Convert the VM into a Template ---------------\033[0m\n"
qm template $VMID

printf "\n------------- Copy downloaded Image file into Templates Folder ---------------\n"
if [[ ! -f /var/lib/vz/template/iso/$VMIMAGE ]] ; then
  cp /tmp/$VMIMAGE /var/lib/vz/template/iso/$VMIMAGE
  printf "$VMIMAGE Copied into /var/lib/vz/template/iso/ \n\n"
else
  printf "$VMIMAGE is Exists\n\n"
fi

while true; do
  read -p "Are you running Proxmox-VE in Cluster Mode and want to distribute the downloaded Image & SSHKEY files to all nodes (yes or no): " yn
  case $yn in
    [Yy]* )
      printf "\nPlease enter the IPs of the Nodes wanted to distribute the downloaded Image file, separated by 'SPACE' (192.168.50.50) : "
      read -a CLUSTER_NODE_IPS
      for i in ${!CLUSTER_NODE_IPS[@]}
      do
        scp ~/.ssh/$SSHKEY_CLIENT_NAME.pub root@${CLUSTER_NODE_IPS[i]}:~/.ssh/
        scp ~/.ssh/$SSHKEY_CLIENT_NAME root@${CLUSTER_NODE_IPS[i]}:~/.ssh/
        printf "\n** $SSHKEY_CLIENT_NAME copied to ${CLUSTER_NODE_IPS[i]}:~/.ssh/ **\n\n"
        scp /tmp/$VMIMAGE root@${CLUSTER_NODE_IPS[i]}:/tmp
        ssh root@${CLUSTER_NODE_IPS[i]} "cp /tmp/$VMIMAGE /var/lib/vz/template/iso/"
        printf "\n** $VMIMAGE copied to ${CLUSTER_NODE_IPS[i]}:/var/lib/vz/template/iso/ & /tmp Folders**\n\n"
      done
      break;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done

printf "\n** Removing previously downloaded image file **\n\n"
rm -v /tmp/$VMIMAGE

printf "$NOTE\n\n"
