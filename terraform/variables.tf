#########################################################################
# Arguments are supported in the Terraform Telmate Proxmox 
# ** Provider Block **
#########################################################################

variable "api_url" {
  description = "This is the target Proxmox API endpoint. REQURIED(or use environment variable PM_API_URL)"
  type        = string
  default     = null
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
  type        = string
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