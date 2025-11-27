# Packer Variables for Debian 13 Template
# File: variables.pkr.hcl

# Proxmox Connection
variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL"
  # No default value - must be set via environment variable PKR_VAR_proxmox_api_url
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox authentication token ID (format: user@realm!tokenname)"
  # No default value - must be set via environment variable PKR_VAR_proxmox_api_token_id
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox authentication token secret"
  # No default value - must be set via environment variable PKR_VAR_proxmox_api_token_secret
  sensitive = true
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
  # No default value - must be set via environment variable PKR_VAR_proxmox_node
}

variable "skip_tls_verify" {
  type        = bool
  description = "Skip TLS verification (use only in development)"
  default     = true
}

# VM Configuration
variable "vm_id" {
  type        = number
  description = "VM template ID"
  default     = 9988
}

variable "template_name" {
  type        = string
  description = "Final template name"
  default     = "debian-13-template"
}

# Hardware Configuration
variable "cpu_cores" {
  type        = number
  description = "Number of CPU cores"
  default     = 2
  validation {
    condition     = var.cpu_cores >= 1 && var.cpu_cores <= 32
    error_message = "CPU cores must be between 1 and 32."
  }
}

variable "memory" {
  type        = number
  description = "RAM memory in MB"
  default     = 1024
  validation {
    condition     = var.memory >= 1024 && var.memory <= 32768
    error_message = "Memory must be between 1024 MB and 32768 MB."
  }
}

variable "disk_size" {
  type        = string
  description = "Disk size"
  default     = "20G"
}

variable "storage_pool" {
  type        = string
  description = "Proxmox storage pool"
  default     = "local-lvm"
}

# Network Configuration
variable "network_bridge" {
  type        = string
  description = "Network bridge"
  default     = "vmbr0"
}

variable "network_vlan" {
  type        = string
  description = "VLAN tag (optional)"
  default     = ""
}

# ISO Configuration
variable "iso_file" {
  type        = string
  description = "Debian ISO file"
  default     = "local:iso/debian-13.2.0-amd64-netinst.iso"
}

# HTTP Configuration
variable "http_directory" {
  type        = string
  description = "Directory containing HTTP configuration files"
  default     = "http"
}

variable "http_port_min" {
  type        = number
  description = "Minimum HTTP port"
  default     = 8800
}

variable "http_port_max" {
  type        = number
  description = "Maximum HTTP port"
  default     = 8899
}

# SSH Configuration
variable "ssh_username" {
  type        = string
  description = "SSH username"
  default     = "user"
}

variable "ssh_password" {
  type        = string
  description = "Temporary SSH password for build"
  # No default value - must be set via environment variable PKR_VAR_ssh_password
  sensitive = true
}

variable "ssh_timeout" {
  type        = string
  description = "SSH timeout"
  default     = "15m"
}

# Files Configuration
variable "files_directory" {
  type        = string
  description = "Directory containing configuration files"
  default     = "./files"
}

# Additional Variables (used in .auto.pkrvars.hcl)
variable "vm_name" {
  type        = string
  description = "VM name (optional, will be generated from template_name if not set)"
  default     = null
}

variable "iso_checksum" {
  type        = string
  description = "ISO checksum (use 'none' for no verification)"
  default     = "none"
}
