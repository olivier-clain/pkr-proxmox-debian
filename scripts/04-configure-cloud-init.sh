#!/bin/bash
# Script 04: Configuration Cloud-Init
# Description: Configure Cloud-Init pour Proxmox

set -euo pipefail

echo "==> Configuration de Cloud-Init..."

CLOUD_CFG_DIR="/etc/cloud/cloud.cfg.d"

# Créer le répertoire si nécessaire
mkdir -p "${CLOUD_CFG_DIR}"

# Copier la configuration Proxmox
if [ -f "/tmp/99-pve.cfg" ]; then
    echo "==> Installation de la configuration Proxmox..."
    mv /tmp/99-pve.cfg "${CLOUD_CFG_DIR}/99-pve.cfg"
fi

# Configuration additionnelle Cloud-Init
cat > "${CLOUD_CFG_DIR}/90-custom.cfg" << 'EOF'
# Configuration personnalisée Cloud-Init

# Désactiver la génération automatique de hostname
preserve_hostname: false

# Gestionnaire de réseau
network:
  config: disabled

# Modules à exécuter
cloud_init_modules:
  - migrator
  - seed_random
  - bootcmd
  - write-files
  - growpart
  - resizefs
  - disk_setup
  - mounts
  - set_hostname
  - update_hostname
  - update_etc_hosts
  - ca-certs
  - rsyslog
  - users-groups
  - ssh

cloud_config_modules:
  - emit_upstart
  - snap
  - ssh-import-id
  - locale
  - set-passwords
  - grub-dpkg
  - apt-pipelining
  - apt-configure
  - ubuntu-advantage
  - ntp
  - timezone
  - disable-ec2-metadata
  - runcmd

cloud_final_modules:
  - package-update-upgrade-install
  - fan
  - landscape
  - lxd
  - ubuntu-drivers
  - write-files-deferred
  - puppet
  - chef
  - mcollective
  - salt-minion
  - reset_rmc
  - refresh_rmc_and_interface
  - rightscale_userdata
  - scripts-vendor
  - scripts-per-once
  - scripts-per-boot
  - scripts-per-instance
  - scripts-user
  - ssh-authkey-fingerprints
  - keys-to-console
  - phone-home
  - final-message
  - power-state-change

# Nettoyage après installation
datasource:
  Ec2:
    strict_id: false
EOF

echo "==> Configuration Cloud-Init terminée"
