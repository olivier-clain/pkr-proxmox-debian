#!/bin/bash
# Script 02: Installation des paquets essentiels
# Description: Installe les outils et paquets nécessaires pour le template

set -euo pipefail

echo "==> Installation des paquets essentiels..."

# Liste des paquets à installer
PACKAGES=(
    # Outils système
    "curl"
    "wget"
    "vim"
    "nano"
    "htop"
    "net-tools"
    "dnsutils"
    "iputils-ping"
    
    # Outils réseau
    "openssh-server"
    "ca-certificates"
    
    # Outils Proxmox/Virtualisation
    "qemu-guest-agent"
    
    # Outils de développement (optionnel)
    "git"
    "python3"
    "python3-pip"
    
    # Outils cloud
    "cloud-init"
    "cloud-initramfs-growroot"
)

# Installation des paquets
echo "==> Installation de ${#PACKAGES[@]} paquets..."
DEBIAN_FRONTEND=noninteractive apt-get install -y "${PACKAGES[@]}"

# Vérification que qemu-guest-agent est installé
if systemctl is-enabled qemu-guest-agent >/dev/null 2>&1; then
    echo "==> QEMU Guest Agent installé et activé"
else
    echo "==> Activation de QEMU Guest Agent..."
    systemctl enable qemu-guest-agent
fi

echo "==> Installation des paquets terminée avec succès"
