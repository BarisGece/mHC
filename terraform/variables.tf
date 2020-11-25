#########################################################################
# Arguments are supported in the Terraform Telmate Proxmox 
# ** Provider Block **
#########################################################################

variable "api_url" {
  description = "This is the target Proxmox API endpoint. REQUIRED(or use environment variable PM_API_URL)"
  type        = string
  default     = "https://proxmox.example.com:8006/api2/json"
}

variable "user" {
  description = "The Proxmox User. REQUIRED(or use environment variable PM_USER)"
  type        = string
  default     = "terraform@pam"
}

variable "password" {
  description = "The Proxmox User Password. REQUIRED(or use environment variable PM_PASS)"
  type        = string
  default     = null
}

variable "otp" {
  description = "The 2FA OTP code. (or use environment variable PM_OTP)"
  type        = string
  default     = null
}

variable "tls_insecure" {
  description = "Disable TLS verification while connecting. Default: false"
  type        = string
  default     = true
}

variable "parallel" {
  description = "Allowed simultaneous Proxmox processes(e.g. creating resources). Default: 4"
  type        = number
  default     = null
}

variable "log_enable" {
  description = "Enable debug logging, see the section below for logging details. Default: false"
  type        = string
  default     = true
}

variable "log_levels" {
  description = "A map of log sources and levels"
  type        = map(object({
    _default          = string
    _capturelog       = string
    }))
  default     = {
    _default    = "debug"
    _capturelog = ""
  }
}

variable "log_file" {
  description = "If logging is enabled, the log file the provider will write logs to. Default: terraform-plugin-proxmox.log"
  type        = string
  default     = "terraform-proxmox.log"
}

variable "timeout" {
  description = "Timeout value (seconds) for proxmox API calls. Default: 300"
  type        = number
  default     = 600
}

#########################################################################
# Arguments are supported in the Terraform Telmate Proxmox 
# ** Resource Block **
#########################################################################

variable "name" {
  description = "Name of the VM. REQUIRED"
  type        = string
  default     = null
}

variable "target_node" {
  description = "Target Proxmox-VE Node to place the VM on. REQUIRED"
  type        = string
  default     = null
}

variable "vmid" {
  description = "The (unique) ID of the VM in Proxmox. Default: next number in the sequence"
  type        = number
  default     = 1000
}

variable "desc" {
  description = "Description for the VM. Only used on the configuration web interface. This is saved as comment inside the configuration file"
  type        = string
  default     = null
}

variable "bios" {
  description = "Select BIOS implementation(ovmf | seabios). Default: seabios"
  type        = string
  default     = "seabios"
}

variable "onboot" {
  description = "Specifies whether a VM will be started during system bootup. Default: true"
  type        = bool
  default     = true
}

variable "boot" {
  description = "Boot on floppy (a), hard disk (c), CD-ROM (d), or network (n). Default: cdn"
  type        = string
  default     = "cdn"
}

variable "bootdisk" {
  description = "Enable booting from specified disk(ide|sata|scsi|virtio)\\d+. Sample: scsi0 or virtio0"
  type        = string
  default     = "scsi0"
}

variable "agent" {
  description = "Enables QEMU Agent option for this VM.  When 1, then qemu-guest-agent must be installed on the guest. Default: 0"
  type        = number
  default     = 1
}

variable "iso" {
  description = "ISO file uploaded on the Proxmox-VE storage. Set only ISO or CLONE. Sample: local:iso/proxmox-mailgateway_2.1.iso"
  type        = string
  default     = null
}

variable "clone" {
  description = "The name of the Proxmox-VE Template. It will be used to provision a new VM by Terraform"
  type        = string
  default     = null
}

variable "full_clone" {
  description = "Whether to run a full or linked clone from the template. Default: true"
  type        = bool
  default     = true
}

variable "hastate" {
  description = "HA, you need to use a shared disk for this feature (ex: rbd)"
  type        = string
  default     = null
}

variable "qemu_os" {
  description = "Specify guest operating system. This is used to enable special optimization/features for specific operating systems. Default: l26"
  type        = string
  default     = "l26"
}

variable "memory" {
  description = "Amount of RAM for the VM in MB. This is the maximum available memory when you use the balloon device. Default: 512"
  type        = number
  default     = 512
}

variable "balloon" {
  description = "Amount of target RAM for the VM in MB. Using 0 disables the ballon driver. Default: 0"
  type        = number
  default     = 1
}

variable "cores" {
  description = "The number of CPU cores per socket to give the VM. Default: 1"
  type        = number
  default     = 1
}

variable "sockets" {
  description = "The number of CPU sockets. Default: 1"
  type        = number
  default     = 1
}

variable "vcpus" {
  description = "Number of hotplugged vCPUs. Default: 0"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "Emulated CPU type. For best performance(homogeneous cluster where all nodes have the same CPU), set this to host. Default: host"
  type        = string
  default     = "host"
}

variable "numa" {
  description = "Enable/disable NUMA. Default: false"
  type        = bool
  default     = true
}

variable "kvm" {
  description = "Enable/disable KVM hardware virtualization. Default: true"
  type        = bool
  default     = true
}

variable "hotplug" {
  description = "Selectively enable hotplug features. This is a comma separated list of hotplug features: network, disk, cpu, memory and usb. Default: network,disk,usb"
  type        = string
  default     = "disk,network,usb,cpu,memory "
}

variable "scsihw" {
  description = "SCSI controller model. (lsi | lsi53c810 | megasas | pvscsi | virtio-scsi-pci | virtio-scsi-single)"
  type        = string
  default     = "virtio-scsi-single"
}

variable "vga" {
  description = "(optional)"
  type = object({
    type   = string
    memory = number
  })
  default = null
}

variable "network" {
  description = "(optional)"
  type = list(object({
    model     = string
    macaddr   = string
    bridge    = string
    tag       = number
    firewall  = bool
    rate      = number
    queues    = number
    link_down = bool
  }))
  default = [
    {
      model     = "virtio"
      macaddr   = null
      bridge    = "vmbr0"
      tag       = null
      firewall  = null
      rate      = null
      queues    = null
      link_down = null
    }
  ]
}

variable "disk" {
  description = "(optional) describe your variable"
  type = list(object({
    type         = string
    storage      = string
    size         = number
    format       = string
    cache        = number
    backup       = bool
    iothread     = bool
    replicate    = bool
    ssd          = bool
    file         = string
    media        = string
    discard      = string
    mbps         = number
    mbps_rd      = number
    mbps_rd_max  = number
    mbps_wr      = number
    mbps_wr_max  = number
    volume       = string
    slog         = string
  }))
  default = []
}

variable "serial" {
  description = "(optional)"
  type = object({
    id   = string
    type = string
  })
  default = null
}

variable "pool" {
  description = "Optional"
  type        = string
  default     = null
}

variable "force_create" {
  description = "Defaults to true"
  type        = string
  default     = false
}

variable "clone_wait" {
  description = "Optional"
  type        = string
  default     = null
}

variable "preprovision" {
  description = "Defaults to true"
  type        = string
  default     = null
}

variable "os_type" {
  description = "Which provisioning method to use, based on the OS type. Possible values: ubuntu, centos, cloud-init."
  type        = string
  default     = null
}

#########################################################################
# Arguments are supported in the Terraform Telmate Proxmox 
# ** Resource Block Cloud Init Specific Variables**
#########################################################################

variable "ci_wait" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "ciuser" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "cipassword" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "cicustom" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "searchdomain" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "nameserver" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "sshkeys" {
  description = "sshkeys"
  type        = string
  default     = null
}

variable "ipconfig0" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "ipconfig1" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "ipconfig2" {
  description = "(optional)"
  type        = string
  default     = null
}
