# 🚀 Guide de Démarrage Rapide - IPs Statiques avec Terraform

Ce guide vous permet de créer et utiliser rapidement un template Debian 13 avec support des IPs statiques.

## ✅ Étape 1 : Prérequis

### Sur Proxmox
```bash
# Créer un utilisateur dédié pour Packer
pveum user add packer@pve
pveum aclmod / -user packer@pve -role PVEVMAdmin

# Créer un token API
pveum user token add packer@pve packer-token --privsep=0
# ⚠️ Sauvegarder le token secret affiché
```

### Télécharger l'ISO Debian
```bash
# Sur votre serveur Proxmox
cd /var/lib/vz/template/iso
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.2.0-amd64-netinst.iso
```

## 🔧 Étape 2 : Configuration

```bash
# Se placer dans le répertoire du projet
cd /home/user/workspace/pkr-proxmox-debian

# Copier le fichier d'exemple
cp .env.example .env

# Éditer le fichier .env avec vos informations
nano .env
```

**Configurer les variables dans `.env` :**
```bash
# Proxmox API
export PKR_VAR_proxmox_api_url="https://votre-proxmox:8006/api2/json"
export PKR_VAR_proxmox_api_token_id="packer@pve!packer-token"
export PKR_VAR_proxmox_api_token_secret="votre-secret-token"
export PKR_VAR_proxmox_node="pve"

# SSH Password (temporaire, uniquement pour la construction)
export PKR_VAR_ssh_password="VotreMotDePasseTemporaire123!"
```

## 🏗️ Étape 3 : Construire le Template

```bash
# Charger les variables d'environnement
source .env

# Initialiser Packer (première fois uniquement)
make init

# Valider la configuration
make validate

# Construire le template
make build
```

**Durée** : ~15-20 minutes

**Résultat** : Template créé dans Proxmox avec ID 9988 (ou personnalisé)

## 🌐 Étape 4 : Déployer une VM avec IP Statique

### Option A : Via Terraform (Recommandé)

**1. Créer un fichier `main.tf` :**
```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://votre-proxmox:8006/api2/json"
  pm_api_token_id     = "terraform@pve!terraform-token"
  pm_api_token_secret = "votre-secret-token"
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "debian_vm" {
  name        = "debian-vm-01"
  target_node = "pve"
  clone       = "debian-13-template-20250124"  # Nom de votre template
  
  cores  = 2
  memory = 2048
  agent  = 1
  
  # ⭐ Configuration IP Statique
  ipconfig0 = "ip=192.168.1.100/24,gw=192.168.1.1"
  
  nameserver = "192.168.1.1"
  
  disk {
    size    = "20G"
    type    = "scsi"
    storage = "local-lvm"
  }
  
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  os_type = "cloud-init"
  ciuser  = "user"
  sshkeys = file("~/.ssh/id_rsa.pub")
}
```

**2. Déployer :**
```bash
# Initialiser Terraform
terraform init

# Vérifier le plan
terraform plan

# Déployer
terraform apply
```

### Option B : Via Interface Proxmox

1. **Créer une VM** à partir du template
2. Aller dans **VM > Cloud-Init**
3. Configurer :
   - IP Address : `192.168.1.100/24`
   - Gateway : `192.168.1.1`
   - DNS : `192.168.1.1`
4. Cliquer sur **Regenerate Image**
5. Démarrer la VM

## ✔️ Étape 5 : Vérifier

```bash
# Se connecter à la VM
ssh user@192.168.1.100

# Vérifier l'IP
ip addr show

# Vérifier la gateway
ip route show

# Tester la connectivité
ping -c 4 8.8.8.8
ping -c 4 google.com

# Voir la documentation embarquée
cat /root/NETWORK-CONFIG-INFO.txt
```

## 📚 Documentation Complète

- **[README.md](README.md)** - Documentation générale du projet
- **[TERRAFORM-STATIC-IPS.md](TERRAFORM-STATIC-IPS.md)** - Guide complet Terraform avec exemples avancés
- **[STATIC-IP-MODIFICATIONS.md](STATIC-IP-MODIFICATIONS.md)** - Détails des modifications techniques
- **[scripts/README.md](scripts/README.md)** - Documentation des scripts

## 🔧 Personnalisation

### Modifier le template

**Ajouter des packages :**
```bash
# Éditer le script d'installation
nano scripts/02-install-packages.sh

# Ajouter vos packages à la liste PACKAGES
PACKAGES=(
    ...
    "votre-package"
)

# Reconstruire le template
make build
```

**Modifier les ressources par défaut :**
```bash
# Éditer les variables
nano variables.auto.pkrvars.hcl

# Exemple : augmenter la RAM
memory = 4096

# Reconstruire
make build
```

## 🆘 Dépannage

### Le template ne se construit pas

**Vérifier les variables :**
```bash
source .env
echo $PKR_VAR_proxmox_api_url
echo $PKR_VAR_proxmox_node
```

**Vérifier l'ISO :**
```bash
# Sur Proxmox
pvesm list local --content iso
```

### La VM n'a pas l'IP statique

**Sur la VM :**
```bash
# Voir les logs Cloud-Init
sudo cat /var/log/cloud-init.log

# Forcer la réinitialisation
sudo cloud-init clean --logs
sudo reboot
```

**Dans Proxmox :**
```bash
# Vérifier la config Cloud-Init de la VM
qm cloudinit dump <vmid> network
```

### Pas de connectivité réseau

**Vérifier la configuration :**
```bash
# Sur la VM
ip addr show        # Vérifier l'IP
ip route show       # Vérifier la gateway
cat /etc/resolv.conf  # Vérifier le DNS
```

## 🎯 Commandes Utiles

### Packer

```bash
make help         # Voir toutes les commandes
make init         # Initialiser Packer
make validate     # Valider la configuration
make build        # Construire le template
make build-debug  # Construire avec logs détaillés
make clean        # Nettoyer le cache
```

### Terraform

```bash
terraform init              # Initialiser
terraform plan              # Voir les changements
terraform apply             # Appliquer
terraform destroy           # Détruire les ressources
terraform show              # Voir l'état actuel
terraform output            # Voir les outputs
```

### Proxmox (CLI)

```bash
qm list                         # Lister les VMs
qm status <vmid>                # État d'une VM
qm cloudinit dump <vmid> all    # Voir config Cloud-Init
pvesm list local --content iso  # Lister les ISOs
```

## 🚀 Prochaines Étapes

1. **Déployer un cluster de VMs** - Voir `TERRAFORM-STATIC-IPS.md` exemple 4
2. **Créer un module réutilisable** - Voir `TERRAFORM-STATIC-IPS.md` exemple 3
3. **Automatiser avec CI/CD** - Intégrer dans votre pipeline
4. **Sécuriser** - Configurer firewall, fail2ban, etc.

## ⚡ Déploiement Rapide (One-Liner)

```bash
# Construction complète du template
cd /home/user/workspace/pkr-proxmox-debian && \
source .env && \
make init && \
make build
```

## 📊 Temps Estimés

| Étape | Durée |
|-------|-------|
| Configuration initiale | 5-10 min |
| Construction du template | 15-20 min |
| Déploiement d'une VM | 2-5 min |
| **Total première utilisation** | **~25-35 min** |
| **Déploiements suivants** | **2-5 min** |

---

**🎉 Vous êtes prêt ! Bon déploiement avec des IPs statiques !**
