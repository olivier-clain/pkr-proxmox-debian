#!/bin/bash
# Script 99: Nettoyage final du template
# Description: Nettoie tous les fichiers temporaires et prépare le template

set -euo pipefail

echo "==> Nettoyage final du template..."

# Nettoyage des clés SSH host (seront régénérées au premier boot)
echo "==> Suppression des clés SSH host..."
rm -f /etc/ssh/ssh_host_*

# Nettoyage des identifiants machine
echo "==> Réinitialisation des identifiants machine..."
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id

# Nettoyage des logs
echo "==> Nettoyage des logs..."
find /var/log -type f -exec truncate -s 0 {} + 2>/dev/null || true
rm -f /var/log/*.gz
rm -f /var/log/*.1
rm -f /var/log/*/*.gz
rm -f /var/log/*/*.1

# Nettoyage APT
echo "==> Nettoyage du cache APT..."
apt-get clean
apt-get autoclean
apt-get autoremove -y --purge

# Nettoyage des caches système
echo "==> Nettoyage des caches..."
rm -rf /var/cache/* 2>/dev/null || true
rm -rf /var/tmp/* 2>/dev/null || true
rm -rf /tmp/* 2>/dev/null || true

# Nettoyage DHCP
echo "==> Nettoyage des leases DHCP..."
rm -f /var/lib/dhcp/*

# Nettoyage de l'historique
echo "==> Nettoyage de l'historique..."
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/*/.bash_history 2>/dev/null || true

# Nettoyage des fichiers temporaires utilisateur
echo "==> Nettoyage des fichiers temporaires utilisateur..."
rm -rf /root/.cache 2>/dev/null || true
rm -rf /home/*/.cache 2>/dev/null || true
rm -rf /root/.wget-hsts 2>/dev/null || true
rm -rf /home/*/.wget-hsts 2>/dev/null || true

# Nettoyage de cloud-init
echo "==> Nettoyage de cloud-init..."
cloud-init clean --logs --seed 2>/dev/null || true

# Nettoyage des persistent network rules (udev)
echo "==> Nettoyage des règles réseau persistantes..."
rm -f /etc/udev/rules.d/70-persistent-net.rules 2>/dev/null || true

# Synchronisation finale
echo "==> Synchronisation des disques..."
sync

echo "==> Nettoyage terminé - Le template est prêt !"
