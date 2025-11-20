#!/bin/bash
# Script Exemple: Installation d'outils personnalisés
# Description: Template pour ajouter vos propres outils et configurations
# 
# Pour utiliser ce script:
# 1. Renommer en XX-votre-nom.sh (où XX est le numéro d'ordre)
# 2. Modifier le contenu selon vos besoins
# 3. Rendre exécutable: chmod +x scripts/XX-votre-nom.sh
# 4. Ajouter dans debian-13.pkr.hcl dans le bloc build

set -euo pipefail

echo "==> Installation d'outils personnalisés..."

# ============================================================================
# Exemple 1: Installation depuis les dépôts APT
# ============================================================================
CUSTOM_PACKAGES=(
    # Exemple: outils de monitoring
    # "htop"
    # "iotop"
    # "nethogs"
    
    # Exemple: outils de développement
    # "build-essential"
    # "git"
    # "docker.io"
)

if [ ${#CUSTOM_PACKAGES[@]} -gt 0 ]; then
    echo "==> Installation de paquets personnalisés..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y "${CUSTOM_PACKAGES[@]}"
fi

# ============================================================================
# Exemple 2: Installation depuis des sources externes
# ============================================================================

# Exemple: Installation de Docker Compose
# echo "==> Installation de Docker Compose..."
# DOCKER_COMPOSE_VERSION="2.23.0"
# curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose

# Exemple: Installation de kubectl
# echo "==> Installation de kubectl..."
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# rm kubectl

# ============================================================================
# Exemple 3: Configuration système personnalisée
# ============================================================================

# Exemple: Configuration du timezone
# echo "==> Configuration du timezone..."
# timedatectl set-timezone Europe/Paris

# Exemple: Configuration de limits
# echo "==> Configuration des limites système..."
# cat >> /etc/security/limits.conf << 'EOF'
# * soft nofile 65536
# * hard nofile 65536
# EOF

# Exemple: Configuration sysctl
# echo "==> Configuration sysctl..."
# cat >> /etc/sysctl.conf << 'EOF'
# # Optimisations réseau
# net.core.somaxconn = 1024
# net.ipv4.tcp_max_syn_backlog = 2048
# EOF
# sysctl -p

# ============================================================================
# Exemple 4: Création de répertoires et fichiers
# ============================================================================

# Exemple: Créer des répertoires standards
# echo "==> Création de répertoires personnalisés..."
# mkdir -p /opt/scripts
# mkdir -p /opt/data
# chmod 755 /opt/scripts /opt/data

# Exemple: Créer un script utilitaire
# cat > /opt/scripts/info.sh << 'EOF'
# #!/bin/bash
# echo "=== Informations Système ==="
# echo "Hostname: $(hostname)"
# echo "IP: $(hostname -I)"
# echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
# echo "Kernel: $(uname -r)"
# EOF
# chmod +x /opt/scripts/info.sh

# ============================================================================
# Exemple 5: Configuration d'utilisateurs et groupes
# ============================================================================

# Exemple: Créer un groupe personnalisé
# echo "==> Création de groupes personnalisés..."
# groupadd -r docker-users || true

# Exemple: Ajouter l'utilisateur à des groupes
# echo "==> Configuration des groupes utilisateur..."
# usermod -aG docker-users user || true

# ============================================================================
# Exemple 6: Installation et configuration d'un service
# ============================================================================

# Exemple: Installation et configuration de Prometheus Node Exporter
# echo "==> Installation de Prometheus Node Exporter..."
# NODE_EXPORTER_VERSION="1.7.0"
# cd /tmp
# wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
# tar xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
# cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
# rm -rf node_exporter-${NODE_EXPORTER_VERSION}*
# 
# # Créer le service systemd
# cat > /etc/systemd/system/node_exporter.service << 'EOF'
# [Unit]
# Description=Prometheus Node Exporter
# After=network.target
# 
# [Service]
# Type=simple
# User=nobody
# ExecStart=/usr/local/bin/node_exporter
# 
# [Install]
# WantedBy=multi-user.target
# EOF
# 
# systemctl daemon-reload
# systemctl enable node_exporter
# systemctl start node_exporter

# ============================================================================
# Exemple 7: Copie de fichiers de configuration
# ============================================================================

# Si vous avez copié des fichiers avec provisioner "file":
# echo "==> Installation de fichiers de configuration..."
# if [ -f "/tmp/custom-config.conf" ]; then
#     mv /tmp/custom-config.conf /etc/myapp/config.conf
#     chown root:root /etc/myapp/config.conf
#     chmod 644 /etc/myapp/config.conf
# fi

echo "==> Installation d'outils personnalisés terminée"

# ============================================================================
# Notes et bonnes pratiques
# ============================================================================
#
# 1. Toujours vérifier si une commande existe avant de l'utiliser:
#    if command -v docker &> /dev/null; then
#        echo "Docker est installé"
#    fi
#
# 2. Utiliser DEBIAN_FRONTEND=noninteractive pour apt-get
#
# 3. Nettoyer après installation:
#    rm -rf /tmp/downloads
#    apt-get clean
#
# 4. Vérifier les codes de sortie:
#    if systemctl enable myservice; then
#        echo "Service activé"
#    else
#        echo "Erreur lors de l'activation"
#        exit 1
#    fi
#
# 5. Logger les actions importantes
#
# 6. Tester le script individuellement avant de l'intégrer
#
# ============================================================================
