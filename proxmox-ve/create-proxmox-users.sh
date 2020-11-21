#!/bin/bash
set -o errexit

PACKER_USER=${PACKER_PVE_USER:-packer}
PACKER_PASSWORD=$PACKER_PVE_PASSWORD

TERRAFORM_USER=${TERRAFORM_PVE_USER:-terraform}
TERRAFORM_PASSWORD=$TERRAFORM_PVE_PASSWORD

ANSIBLE_USER=${ANSIBLE_PVE_USER:-ansible}
ANSIBLE_PASSWORD=$ANSIBLE_PVE_PASSWORD

if [[ -z $PACKER_PVE_PASSWORD ]]; then
  printf "\n** \033[1;31mCould not find Packer PVE Password as Environment Variable\033[0m **\n"
  read -s -p "Please set PACKER_PVE_PASSWORD password (at least 12 or 14 character): " PACKER_PVE_PASSWORD
  export PACKER_PVE_PASSWORD=$PACKER_PVE_PASSWORD
  printf "\n** \033[1;33mPACKER_PVE_PASSWORD Set\033[0m **\n"

  printf "\n** \033[1;33m$PACKER_USER will be created\033[0m **\n"
  pveum useradd $PACKER_USER@pve --password $PACKER_PVE_PASSWORD -comment "Packer Admin"
  pveum aclmod / -user $PACKER_USER@pve -role Administrator
  printf "\n** \033[1;33m$PACKER_USER created with Administrator Role\033[0m **\n"
else
  printf "\n** \033[1;33m$PACKER_USER will be created\033[0m **\n"
  pveum useradd $PACKER_USER@pve --password $PACKER_PVE_PASSWORD -comment "Packer Admin"
  pveum aclmod / -user $PACKER_USER@pve -role Administrator
  printf "\n** \033[1;33m$PACKER_USER created with Administrator Role\033[0m **\n"
fi

if [[ -z $TERRAFORM_PVE_PASSWORD ]]; then
  printf "\n** \033[1;31mCould not find Terraform PVE Password as Environment Variable\033[0m **\n"
  read -s -p "Please set TERRAFORM_PVE_PASSWORD password (at least 12 or 14 character): " TERRAFORM_PVE_PASSWORD
  export TERRAFORM_PVE_PASSWORD=$TERRAFORM_PVE_PASSWORD
  printf "\n** \033[1;33mTERRAFORM_PVE_PASSWORD Set\033[0m **\n"

  printf "\n** \033[1;33m$TERRAFORM_USER will be created\033[0m **\n"
  pveum useradd $TERRAFORM_USER@pve --password $TERRAFORM_PVE_PASSWORD -comment "Terraform Admin"
  pveum aclmod / -user $TERRAFORM_USER@pve -role Administrator
  printf "\n** \033[1;33m$TERRAFORM_USER created with Administrator Role\033[0m **\n"
else
  printf "\n** \033[1;33m$TERRAFORM_USER will be created\033[0m **\n"
  pveum useradd $TERRAFORM_USER@pve --password $TERRAFORM_PVE_PASSWORD -comment "Terraform Admin"
  pveum aclmod / -user $TERRAFORM_USER@pve -role Administrator
  printf "\n** \033[1;33m$TERRAFORM_USER created with Administrator Role\033[0m **\n"
fi

if [[ -z $ANSIBLE_PVE_PASSWORD ]]; then
  printf "\n** \033[1;31mCould not find Ansible PVE Password as Environment Variable\033[0m **\n"
  read -s -p "Please set ANSIBLE_PVE_PASSWORD password (at least 12 or 14 character): " ANSIBLE_PVE_PASSWORD
  export ANSIBLE_PVE_PASSWORD=$ANSIBLE_PVE_PASSWORD
  printf "\n** \033[1;33mANSIBLE_PVE_PASSWORD Set\033[0m **\n"

  printf "\n** \033[1;33m$ANSIBLE_USER will be created\033[0m **\n"
  pveum useradd $ANSIBLE_USER@pve --password $ANSIBLE_PVE_PASSWORD -comment "Ansible Admin"
  pveum aclmod / -user $ANSIBLE_USER@pve -role Administrator
  printf "\n** \033[1;33m$ANSIBLE_USER created with Administrator Role\033[0m **\n"
else
  printf "\n** \033[1;33m$ANSIBLE_USER will be created\033[0m **\n"
  pveum useradd $ANSIBLE_USER@pve --password $ANSIBLE_PVE_PASSWORD -comment "Ansible Admin"
  pveum aclmod / -user $ANSIBLE_USER@pve -role Administrator
  printf "\n** \033[1;33m$ANSIBLE_USER created with Administrator Role\033[0m **\n"
fi
