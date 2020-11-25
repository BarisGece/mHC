terraform {
  required_version = ">= 0.13.5"
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.5"
    }
  }
}