#!/bin/bash
# Script 01: Mise à jour du système
# Description: Met à jour tous les paquets du système

set -euo pipefail

echo "==> Mise à jour du système Debian..."

# Mise à jour de la liste des paquets
echo "==> Mise à jour de la liste des paquets..."
apt-get update

# Mise à jour des paquets installés
echo "==> Mise à niveau des paquets..."
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Mise à niveau complète si nécessaire
echo "==> Mise à niveau complète..."
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

echo "==> Système mis à jour avec succès"
