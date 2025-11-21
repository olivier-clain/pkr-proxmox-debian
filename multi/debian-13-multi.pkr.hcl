# Debian Server 13.2.0 - Multi-Hypervisor Build
# This template builds on 3 Proxmox hypervisors simultaneously
# Locals are defined in packer.pkr.hcl

# =============================================================================
# SOURCE: Hypervisor 1 - 10.0.0.240
# =============================================================================
source "proxmox-iso" "debian-hv1" {
  # Proxmox Connection
  proxmox_url = var.proxmox_api_url_hv1
  username    = var.proxmox_api_token_id_hv1
  token       = var.proxmox_api_token_secret_hv1
  node        = var.proxmox_node_hv1

  # TLS Security
  insecure_skip_tls_verify = true

  # VM Configuration
  vm_id                = 9001
  vm_name              = local.vm_name
  template_name        = "${var.template_name}-${local.build_date}"
  template_description = local.template_desc
  tags                 = local.default_tags

  boot_iso {
    type     = "scsi"
    iso_file = var.iso_file
    unmount  = true
  }

  # System
  qemu_agent = true
  os         = "l26"

  # Storage
  scsi_controller = "virtio-scsi-single"
  disks {
    disk_size    = var.disk_size
    format       = "raw"
    storage_pool = var.storage_pool
    type         = "scsi"
    cache_mode   = "writethrough"
    io_thread    = true
  }

  # CPU
  cores    = var.cpu_cores
  sockets  = 1
  cpu_type = "host"

  # Memory
  memory = var.memory

  # Network
  network_adapters {
    model    = "virtio"
    bridge   = var.network_bridge
    firewall = false
    vlan_tag = var.network_vlan != "" ? var.network_vlan : null
  }

  # EFI Configuration
  efi_config {
    efi_storage_pool  = var.storage_pool
    pre_enrolled_keys = true
  }

  # Boot configuration
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end><wait>",
    " auto=true priority=critical",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    " debconf/frontend=noninteractive",
    " locale=fr_FR.UTF-8",
    " console-setup/ask_detect=false",
    " keyboard-configuration/xkb-keymap=fr",
    " kbd-chooser/method=fr",
    " auto-install/enable=true",
    " fb=false",
    " DEBCONF_DEBUG=5<wait>",
    "<f10><wait>"
  ]
  boot      = "order=scsi0;ide2"
  boot_wait = "10s"

  # HTTP Configuration - Port 8100 for HV1
  http_directory = var.http_directory
  http_port_min  = 8100
  http_port_max  = 8100

  # SSH
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout
  communicator = "ssh"

  # Machine type
  machine = "q35"
  bios    = "ovmf"
}

# =============================================================================
# SOURCE: Hypervisor 2 - 10.0.0.235
# =============================================================================
source "proxmox-iso" "debian-hv2" {
  # Proxmox Connection
  proxmox_url = var.proxmox_api_url_hv2
  username    = var.proxmox_api_token_id_hv2
  token       = var.proxmox_api_token_secret_hv2
  node        = var.proxmox_node_hv2

  # TLS Security
  insecure_skip_tls_verify = true

  # VM Configuration
  vm_id                = 9002
  vm_name              = local.vm_name
  template_name        = "${var.template_name}-${local.build_date}"
  template_description = local.template_desc
  tags                 = local.default_tags

  boot_iso {
    type     = "scsi"
    iso_file = var.iso_file
    unmount  = true
  }

  # System
  qemu_agent = true
  os         = "l26"

  # Storage
  scsi_controller = "virtio-scsi-single"
  disks {
    disk_size    = var.disk_size
    format       = "raw"
    storage_pool = var.storage_pool
    type         = "scsi"
    cache_mode   = "writethrough"
    io_thread    = true
  }

  # CPU
  cores    = var.cpu_cores
  sockets  = 1
  cpu_type = "host"

  # Memory
  memory = var.memory

  # Network
  network_adapters {
    model    = "virtio"
    bridge   = var.network_bridge
    firewall = false
    vlan_tag = var.network_vlan != "" ? var.network_vlan : null
  }

  # EFI Configuration
  efi_config {
    efi_storage_pool  = var.storage_pool
    pre_enrolled_keys = true
  }

  # Boot configuration
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end><wait>",
    " auto=true priority=critical",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    " debconf/frontend=noninteractive",
    " locale=fr_FR.UTF-8",
    " console-setup/ask_detect=false",
    " keyboard-configuration/xkb-keymap=fr",
    " kbd-chooser/method=fr",
    " auto-install/enable=true",
    " fb=false",
    " DEBCONF_DEBUG=5<wait>",
    "<f10><wait>"
  ]
  boot      = "order=scsi0;ide2"
  boot_wait = "10s"

  # HTTP Configuration - Port 8101 for HV2
  http_directory = var.http_directory
  http_port_min  = 8101
  http_port_max  = 8101

  # SSH
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout
  communicator = "ssh"

  # Machine type
  machine = "q35"
  bios    = "ovmf"
}

# =============================================================================
# SOURCE: Hypervisor 3 - 10.0.0.245
# =============================================================================
source "proxmox-iso" "debian-hv3" {
  # Proxmox Connection
  proxmox_url = var.proxmox_api_url_hv3
  username    = var.proxmox_api_token_id_hv3
  token       = var.proxmox_api_token_secret_hv3
  node        = var.proxmox_node_hv3

  # TLS Security
  insecure_skip_tls_verify = true

  # VM Configuration
  vm_id                = 9003
  vm_name              = local.vm_name
  template_name        = "${var.template_name}-${local.build_date}"
  template_description = local.template_desc
  tags                 = local.default_tags

  boot_iso {
    type     = "scsi"
    iso_file = var.iso_file
    unmount  = true
  }

  # System
  qemu_agent = true
  os         = "l26"

  # Storage
  scsi_controller = "virtio-scsi-single"
  disks {
    disk_size    = var.disk_size
    format       = "raw"
    storage_pool = var.storage_pool
    type         = "scsi"
    cache_mode   = "writethrough"
    io_thread    = true
  }

  # CPU
  cores    = var.cpu_cores
  sockets  = 1
  cpu_type = "host"

  # Memory
  memory = var.memory

  # Network
  network_adapters {
    model    = "virtio"
    bridge   = var.network_bridge
    firewall = false
    vlan_tag = var.network_vlan != "" ? var.network_vlan : null
  }

  # EFI Configuration
  efi_config {
    efi_storage_pool  = var.storage_pool
    pre_enrolled_keys = true
  }

  # Boot configuration
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end><wait>",
    " auto=true priority=critical",
    " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    " debconf/frontend=noninteractive",
    " locale=fr_FR.UTF-8",
    " console-setup/ask_detect=false",
    " keyboard-configuration/xkb-keymap=fr",
    " kbd-chooser/method=fr",
    " auto-install/enable=true",
    " fb=false",
    " DEBCONF_DEBUG=5<wait>",
    "<f10><wait>"
  ]
  boot      = "order=scsi0;ide2"
  boot_wait = "10s"

  # HTTP Configuration - Port 8102 for HV3
  http_directory = var.http_directory
  http_port_min  = 8102
  http_port_max  = 8102

  # SSH
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout
  communicator = "ssh"

  # Machine type
  machine = "q35"
  bios    = "ovmf"
}

# =============================================================================
# BUILD - All 3 Hypervisors
# =============================================================================
build {
  name = "debian-13-multi-template"
  sources = [
    "source.proxmox-iso.debian-hv1",
    "source.proxmox-iso.debian-hv2",
    "source.proxmox-iso.debian-hv3"
  ]

  # Script 1: System update
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "${local.scripts_dir}/01-update-system.sh"
    ]
  }

  # Script 2: Essential packages installation
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "${local.scripts_dir}/02-install-packages.sh"
    ]
  }

  # Script 3: SSH configuration
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "${local.scripts_dir}/03-configure-ssh.sh"
    ]
  }

  # Copy Cloud-Init configuration file
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Script 4: Cloud-Init configuration
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "${local.scripts_dir}/04-configure-cloud-init.sh"
    ]
  }

  # Script 99: Final cleanup
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "${local.scripts_dir}/99-cleanup.sh"
    ]
    pause_before = "10s"
  }
}
