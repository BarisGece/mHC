#########################################################################
# Arguments are supported in the Terraform Telmate Proxmox 
# ** Provider Block **
#########################################################################

variable "api_url" {
  description = "This is the target Proxmox API endpoint. REQURIED(or use environment variable PM_API_URL)"
  type        = string
  default     = "https://proxmox.example.com:8006/api2/json"
}

variable "user" {
  description = "The Proxmox User. REQURIED(or use environment variable PM_USER)"
  type        = string
  default     = "terraform@pam"
}

variable "password" {
  description = "The Proxmox User Password. REQURIED(or use environment variable PM_PASS)"
  type        = string
  default     = null
}

variable "otp" {
  description = "The 2FA OTP code. (or use environment variable PM_OTP)"
  type        = string
  default     = null
}

variable "tls_insecure" {
  description = " Disable TLS verification while connecting"
  type        = string
  default     = true
}

variable "parallel" {
  description = "Allowed simultaneous Proxmox processes(e.g. creating resources). Default 4"
  type        = number
  default     = null
}

variable "log_enable" {
  description = "Enable debug logging, see the section below for logging details. Default false"
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
  description = "If logging is enabled, the log file the provider will write logs to. Default terraform-plugin-proxmox.log"
  type        = string
  default     = "terraform-proxmox.log"
}

variable "timeout" {
  description = "Timeout value (seconds) for proxmox API calls. Default 300"
  type        = number
  default     = 600
}

#########################################################################
# Arguments are supported in the Terraform Telmate Proxmox 
# ** Resource Block **
#########################################################################

variable "name" {
  description = "Name of the VM"
  type        = string
  default     = null
}

variable "target_node" {
  description = "Node to place the VM on"
  type        = string
  default     = null
}

variable "vmid" {
  description = "ID of the VM in Proxmox, defaults to next number in the sequence"
  type        = string
  default     = null
}

variable "desc" {
  description = "Description of the VM"
  type        = string
  default     = null
}

variable "bios" {
  description = "Defaults to seabios"
  type        = string
  default     = "seabios"
}

variable "onboot" {
  description = "Defaults to true"
  type        = bool
  default     = true
}

variable "boot" {
  description = "Defaults to cdn"
  type        = string
  default     = "cdn"
}

variable "bootdisk" {
  description = "Defaults to true"
  type        = string
  default     = "true"
}

variable "agent" {
  description = "Defaults to 0"
  type        = number
  default     = 1
}

variable "iso" {
  description = "Optional"
  type        = string
  default     = null
}

variable "clone" {
  description = "Optional"
  type        = string
  default     = null
}

variable "full_clone" {
  description = "Optional"
  type        = bool
  default     = true
}

variable "hastate" {
  description = "Optional"
  type        = string
  default     = null
}

variable "qemu_os" {
  description = "Defaults to l26"
  type        = string
  default     = "l26"
}

variable "memory" {
  description = "Defaults to 512"
  type        = number
  default     = 512
}

variable "balloon" {
  description = "Defaults to 0"
  type        = number
  default     = 0
}

variable "cores" {
  description = "Defaults to 1"
  type        = number
  default     = 1
}

variable "sockets" {
  description = "Defaults to 1"
  type        = number
  default     = 1
}

variable "vcpus" {
  description = "Defaults to 1"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "Defaults to host"
  type        = string
  default     = "host"
}

variable "numa" {
  description = "Defaults to false"
  type        = bool
  default     = false
}

variable "hotplug" {
  description = "Defaults to network,disk,usb"
  type        = string
  default     = "network,disk,usb"
}

variable "scsihw" {
  description = "Defaults to the empty string"
  type        = string
  default     = null
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
