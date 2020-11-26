#########################################################################################
# Arguments are supported in the Terraform Telmate Proxmox 
# ** Provider Block **
#########################################################################################

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
  type = map(object({
    _default    = string
    _capturelog = string
  }))
  default = {
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

#########################################################################################
# Arguments are supported in the Terraform Telmate Proxmox 
# ** Resource Block **
#########################################################################################

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

/*
 ** memory :                - Sets the VGA memory (in MiB). Has no effect with serial display. (4 - 512)
 ** type   : Default: "std" - Set the VGA type (cirrus | none | qxl | qxl2 | qxl3 | qxl4 | serial0 | serial1 | serial2 | serial3 | std | virtio | vmware)
*/
variable "vga" {
  description = "Configure the VGA Hardware. Default(for type): std"
  type = object({
    type   = string
    memory = number
  })
  default = null
}

/*
  ** model     : REQUIRED       - Network Card Model. The virtio model provides the best performance with very low CPU overhead
                                  If your guest does not support this driver, it is usually best to use e1000
                                  (e1000 | e1000-82540em | e1000-82544gc | e1000-82545em | i82551 | i82557b | i82559er | ne2k_isa | ne2k_pci | pcnet | rtl8139 | virtio | vmxnet3)
  ** macaddr   :                - A common MAC address with the I/G (Individual/Group) bit not set
  ** bridge    : Default: "nat" - However; The Proxmox VE standard bridge is called vmbr0. Bridge to attach the network device to
  ** tag       : Default: -1    - VLAN tag to apply to packets on this interface. (1 - 4094)
  ** firewall  : Default: false - Whether this interface should be protected by the firewall
  ** rate      :                - Rate limit in mbps (megabytes per second) as floating point number. (0 - N)
  ** queues    :                - Number of packet queues to be used on the device. (0 - 16)
  ** link_down :                - Whether this interface should be disconnected (like pulling the plug)
*/
variable "network" {
  description = "Specify network devices"
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
      firewall  = false
      rate      = null
      queues    = null
      link_down = false
    }
  ]
}

/*
  ** type        : REQUIRED        - Disk Type - (ide|sata|scsi|virtio)
  ** storage     : REQUIRED        - Target storage
  ** size        : REQUIRED        - Disk size. This is purely informational and has no effect
  ** format      :                 - Set the drive’s backing file’s data format (cloop | cow | qcow | qcow2 | qed | raw | vmdk)
  ** cache       : Default: "none" - Set the drive’s cache mode (directsync | none | unsafe | writeback | writethrough)
  ** backup      : Default: false  - Whether the drive should be included when making backups
  ** iothread    : Default: false  - Whether to use iothreads for this drive
  ** replicate   : Default: false  - Whether the drive should considered for replication jobs
  ** ssd         :                 - Whether to expose this drive as an SSD, rather than a rotational hard disk
  ** discard     :                 - Controls whether to pass discard/trim requests to the underlying storage
  ** mbps        : Default: 0      - Maximum r/w speed in megabytes per second
  ** mbps_rd     : Default: 0      - Maximum read speed in megabytes per second
  ** mbps_rd_max : Default: 0      - Maximum unthrottled read pool in megabytes per second
  ** mbps_wr     : Default: 0      - Maximum write speed in megabytes per second
  ** mbps_wr_max : Default: 0      - Maximum unthrottled write pool in megabytes per second
  ** file        :                 - The drive’s backing volume
  ** media       :                 - Set the drive’s media type (cdrom | disk)
  ** volume      :                 -
  ** slot        :                 -
*/
variable "disk" {
  description = "Specify disk variables"
  type = list(object({
    type        = string
    storage     = string
    size        = string
    format      = string
    cache       = string
    backup      = bool
    iothread    = bool
    replicate   = bool
    ssd         = bool
    discard     = string
    mbps        = number
    mbps_rd     = number
    mbps_rd_max = number
    mbps_wr     = number
    mbps_wr_max = number
    file        = string
    media       = string
    volume      = string
    slot        = number
  }))
  default = [
    {
      type        = "scsi"
      storage     = "local-lvm"
      size        = "32G"
      format      = "raw"
      cache       = "none"
      backup      = true
      iothread    = true
      replicate   = true
      ssd         = null
      discard     = "on"
      mbps        = null
      mbps_rd     = null
      mbps_rd_max = null
      mbps_wr     = null
      mbps_wr_max = null
      file        = null
      media       = "disk"
      volume      = null
      slot        = null
    }
  ]
}

/*
 ** id     : REQUIRED - ID is 0 to 3
 ** type   : REQUIRED - socket
*/
variable "serial" {
  description = "Create a serial device inside the VM. Serial interface of type socket is used by xterm.js. Using a serial device as terminal"
  type = object({
    id   = number
    type = string
  })
  default = {
    id   = 0
    type = "socket"
  }
}

variable "pool" {
  description = "The destination resource pool for the new VM"
  type        = string
  default     = null
}

variable "force_create" {
  description = "Default: false"
  type        = string
  default     = false
}

variable "clone_wait" {
  description = "Giving time(second) to Proxmox-VE to catchup. Default: 15"
  type        = number
  default     = null
}

#########################################################################################
# ** The following arguments are specifically for Linux for preprovisioning **
# ** It phase which is used to set a hostname, intialize eth0, and resize the VM disk **
# ** REQUIRES define_connection_info to be TRUE **
#########################################################################################
variable "define_connection_info" {
  description = "Define the (SSH) connection parameters for preprovisioners. It allow user to opt-out of setting the connection info for the resource. Default: true"
  type        = bool
  default     = true
}

variable "preprovision" {
  description = "Enable/Disabled Pre-Provisioning. For more detail Telmate vm_qemu.md. Default: true"
  type        = bool
  default     = true
}

variable "os_type" {
  description = "Which provisioning method to use, based on the OS type. Possible values: ubuntu, centos, cloud-init. For more detail Telmate vm_qemu.md"
  type        = string
  default     = "cloud-init"
}

variable "os_network_config" {
  description = "Linux provisioning specific, /etc/network/interfaces for Ubuntu and /etc/sysconfig/network-scripts/ifcfg-eth0 for CentOS"
  type        = string
  default     = null
}

variable "ssh_forward_ip" {
  description = "Address used to connect to the VM"
  type        = string
  default     = null
}

variable "ssh_host" {
  description = "Hostname or IP Address used to connect to the VM"
  type        = string
  default     = null
}

variable "ssh_port" {
  description = "SSH port used to connect to the VM"
  type        = string
  default     = null
}

variable "ssh_user" {
  description = "Username to login in the VM when preprovisioning"
  type        = string
  default     = null
}

variable "ssh_private_key" {
  description = "Private key to login in the VM when preprovisioning"
  type        = string
  default     = null
}

#########################################################################################
# Arguments are supported in the Terraform Telmate Proxmox 
# ** Resource Block Cloud Init Specific Variables **
# ** Also the following arguments are specifically for Cloud-init for preprovisioning **
#########################################################################################

variable "ci_wait" {
  description = "Cloud-init specific, how to long to wait for preprovisioning. Default: 30"
  type        = number
  default     = null
}

variable "ciuser" {
  description = "Cloud-init specific, Overwrite image Default User"
  type        = string
  default     = null
}

variable "cipassword" {
  description = "Cloud-init specific, Password to assign the user. Using this is generally not recommended. Use ssh keys instead"
  type        = string
  default     = null
}

variable "cicustom" {
  description = "Cloud-init specific, location of the custom cloud-config files"
  type        = string
  default     = null
}

variable "searchdomain" {
  description = "Cloud-init specific, sets DNS search domains for a container"
  type        = string
  default     = null
}

variable "nameserver" {
  description = "Cloud-init specific, sets DNS server IP address for a container"
  type        = string
  default     = null
}

variable "sshkeys" {
  description = "Setup public SSH keys (one key per line, OpenSSH format)"
  type        = string
  default     = null
}

variable "ipconfig0" {
  description = "Cloud-init specific, Specify IP addresses and gateways for the corresponding interface. [gw=] [,gw6=] [,ip=<IPv4Format/CIDR>] [,ip6=<IPv6Format/CIDR>]"
  type        = string
  default     = null
}

variable "ipconfig1" {
  description = "Cloud-init specific, Specify IP addresses and gateways for the corresponding interface. [gw=] [,gw6=] [,ip=<IPv4Format/CIDR>] [,ip6=<IPv6Format/CIDR>]"
  type        = string
  default     = null
}

variable "ipconfig2" {
  description = "Cloud-init specific, Specify IP addresses and gateways for the corresponding interface. [gw=] [,gw6=] [,ip=<IPv4Format/CIDR>] [,ip6=<IPv6Format/CIDR>]"
  type        = string
  default     = null
}

variable "force_recreate_on_change_of" {
  description = "Allows this to depend on another resource, that when changed, needs to re-create this vm. An example where this is useful is a cloudinit configuration (as the cicustom attribute points to a file not the content)"
  type        = string
  default     = null
}
