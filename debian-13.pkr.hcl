# Debian Server 13.2.0
# Corrected Packer Template for Proxmox VE - Working version

source "proxmox-iso" "debian13" {

  # Proxmox Connection - corrected syntax
  proxmox_url = var.proxmox_api_url
  username    = var.proxmox_api_token_id
  token       = var.proxmox_api_token_secret
  node        = var.proxmox_node

  # TLS Security
  insecure_skip_tls_verify = var.skip_tls_verify

  # VM Configuration
  vm_id                = var.vm_id
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
  os         = "l26" # Linux 2.6+ kernel

  # Storage - corrected blocks syntax
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

  # Network - corrected blocks syntax
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
    "<esc><wait>",                   # Access GRUB
    "e<wait>",                       # Enter editor
    "<down><down><down><end><wait>", # Move to end of 'linux' line

    # The right parameters
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

    "<f10><wait>" # Boot from GRUB
  ]
  boot      = "order=scsi0;ide2"
  boot_wait = "10s"

  # HTTP Configuration
  http_directory = var.http_directory
  http_port_min  = var.http_port_min
  http_port_max  = var.http_port_max

  # SSH
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout
  communicator = "ssh"
  # Optimized machine type
  machine = "q35"
  bios    = "ovmf"
}

build {
  name    = "debian-13-template"
  sources = ["source.proxmox-iso.debian13"]

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
    # Pause after cleanup to ensure everything is finished
    pause_before = "10s"
  }
}