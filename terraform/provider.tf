terraform {
  required_version = ">= 0.13.5"
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.5"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.api_url
  pm_user         = var.user
  pm_password     = var.password
  pm_tls_insecure = var.tls_insecure
  pm_log_enable   = var.log_enable
  pm_log_levels   = var.log_levels
  pm_log_file     = var.log_file
  pm_timeout      = var.timeout
}
