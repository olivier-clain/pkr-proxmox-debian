# Main Packer configuration
# Defines required plugins and versions

packer {
  required_version = ">= 1.9.0"

  required_plugins {
    proxmox = {
      version = ">= 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Shared locals for all builds
locals {
  # Timestamp for unique naming
  build_date    = formatdate("YYYYMMDD", timestamp())
  build_time    = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  build_version = formatdate("YYYY.MM.DD.hhmm", timestamp())
  
  # Standardized naming
  vm_name       = "${var.template_name}-${local.build_date}"
  template_desc = "Debian 13.2.0 Template - Build ${local.build_date} - Created ${local.build_time}"
  
  # Scripts paths
  scripts_dir = "${path.root}/scripts"
  
  # Standardized tags
  default_tags = "template;packer;debian13;automated"
}