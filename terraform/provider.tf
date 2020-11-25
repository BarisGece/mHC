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
