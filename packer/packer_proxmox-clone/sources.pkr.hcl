# Files need to be suffixed with '.pkr.hcl' to be visible to Packer.
# To use multiple files at once they also need to be in the same folder.
# 'packer inspect folder/' will describe to you what is in that folder.

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source

source "proxmox-clone" "mhc" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_api_user
  password                 = var.proxmox_api_password
  node                     = var.proxmox_node_name
  clone_vm                 = var.clone_vm_name
  insecure_skip_tls_verify = true
  pool                     = var.pool_name
  vm_name                  = var.vm_name
  vm_id                    = var.vm_id
  memory                   = var.memory
  cores                    = var.cores
  sockets                  = var.sockets
  cpu_type                 = var.cpu_type
  os                       = var.os_type
  vga {
    type = var.vga_type
  }
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    storage_pool      = var.storage_pool
    storage_pool_type = var.storage_pool_type
    type              = "scsi"
    disk_size         = var.disk_size
    cache_mode        = "none"
    format            = "raw"
    io_thread         = true // Requires scsi_controller = "virtio-scsi-single"
  }
  template_name        = var.template_name
  template_description = var.template_description
  onboot               = false
  qemu_agent           = true
  disable_kvm          = false
  scsi_controller      = "virtio-scsi-single"
  full_clone           = true

  ssh_timeout          = "90m"
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  #ssh_password         = var.ssh_password
}
