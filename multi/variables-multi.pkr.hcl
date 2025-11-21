# Variables for Multi-Hypervisor Build
# This file extends variables.pkr.hcl with multi-hypervisor support

# =============================================================================
# Multi-Hypervisor Configuration
# =============================================================================

# Hypervisor 1 - 10.0.0.240
variable "proxmox_api_url_hv1" {
  type        = string
  description = "Proxmox API URL for Hypervisor 1 (10.0.0.240)"
  sensitive   = true
  default     = ""
}

variable "proxmox_api_token_id_hv1" {
  type        = string
  description = "Proxmox API token ID for Hypervisor 1"
  sensitive   = true
  default     = ""
}

variable "proxmox_api_token_secret_hv1" {
  type        = string
  description = "Proxmox API token secret for Hypervisor 1"
  sensitive   = true
  default     = ""
}

variable "proxmox_node_hv1" {
  type        = string
  description = "Proxmox node name for Hypervisor 1"
  default     = "server240"
}

# Hypervisor 2 - 10.0.0.235
variable "proxmox_api_url_hv2" {
  type        = string
  description = "Proxmox API URL for Hypervisor 2 (10.0.0.235)"
  sensitive   = true
  default     = ""
}

variable "proxmox_api_token_id_hv2" {
  type        = string
  description = "Proxmox API token ID for Hypervisor 2"
  sensitive   = true
  default     = ""
}

variable "proxmox_api_token_secret_hv2" {
  type        = string
  description = "Proxmox API token secret for Hypervisor 2"
  sensitive   = true
  default     = ""
}

variable "proxmox_node_hv2" {
  type        = string
  description = "Proxmox node name for Hypervisor 2"
  default     = "server235"
}

# Hypervisor 3 - 10.0.0.245
variable "proxmox_api_url_hv3" {
  type        = string
  description = "Proxmox API URL for Hypervisor 3 (10.0.0.245)"
  sensitive   = true
  default     = ""
}

variable "proxmox_api_token_id_hv3" {
  type        = string
  description = "Proxmox API token ID for Hypervisor 3"
  sensitive   = true
  default     = ""
}

variable "proxmox_api_token_secret_hv3" {
  type        = string
  description = "Proxmox API token secret for Hypervisor 3"
  sensitive   = true
  default     = ""
}

variable "proxmox_node_hv3" {
  type        = string
  description = "Proxmox node name for Hypervisor 3"
  default     = "server245"
}
