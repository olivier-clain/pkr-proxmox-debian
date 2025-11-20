#!/bin/bash
# Script 03: Configuration SSH
# Description: Configure le serveur SSH pour la sécurité et les bonnes pratiques

set -euo pipefail

echo "==> Configuration du serveur SSH..."

SSH_CONFIG="/etc/ssh/sshd_config"

# Backup de la configuration originale
if [ ! -f "${SSH_CONFIG}.orig" ]; then
    echo "==> Sauvegarde de la configuration SSH originale..."
    cp "${SSH_CONFIG}" "${SSH_CONFIG}.orig"
fi

# Configuration SSH sécurisée
echo "==> Application des paramètres de sécurité SSH..."

# Désactiver l'authentification par mot de passe root (sera réactivé selon besoin)
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' "${SSH_CONFIG}"

# Activer l'authentification par clé publique
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' "${SSH_CONFIG}"

# Désactiver les authentifications dangereuses
sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' "${SSH_CONFIG}"
sed -i 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' "${SSH_CONFIG}"

# Améliorer la sécurité
sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' "${SSH_CONFIG}"
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "${SSH_CONFIG}"

# S'assurer que SSH démarre au boot
echo "==> Activation du service SSH au démarrage..."
systemctl enable ssh

echo "==> Configuration SSH terminée"
