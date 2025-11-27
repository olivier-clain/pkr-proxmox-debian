# 🇫🇷 Guide Terraform - IPs Statiques

> Guide complet en français pour déployer des VMs Debian avec IPs statiques via Terraform

## 📋 Table des Matières

- [Vue d'ensemble](#vue-densemble)
- [Configuration](#configuration)
- [Exemples](#exemples)
- [Dépannage](#dépannage)
- [Ressources](#ressources)

## Vue d'ensemble

Ce template Debian 13 est **configuré pour supporter les IPs statiques** via Terraform et l'API Proxmox. Cloud-Init ne gère pas la configuration réseau, permettant à Terraform de contrôler complètement les paramètres réseau.

### ✨ Fonctionnalités

- ✅ Configuration d'IPs statiques via Terraform
- ✅ Support multi-interfaces réseau
- ✅ Configuration DNS personnalisée
- ✅ Gestion des VLANs
- ✅ Documentation embarquée dans le template

## Configuration

### Prérequis

```bash
# Installer le provider Terraform
terraform init
```

### Provider Proxmox

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
  pm_api_url          = "https://proxmox.local:8006/api2/json"
  pm_api_token_id     = "terraform@pve!terraform-token"
  pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure     = true  # Uniquement en dev
}
```

## Exemples

### 1️⃣ VM Simple avec IP Statique

```hcl
resource "proxmox_vm_qemu" "debian_simple" {
  name        = "debian-vm-01"
  target_node = "pve"
  clone       = "debian-13-template-20250124"
  
  cores  = 2
  memory = 2048
  agent  = 1
  
  # IP Statique
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

### 2️⃣ Cluster de 3 VMs

```hcl
resource "proxmox_vm_qemu" "debian_cluster" {
  count = 3
  
  name        = "debian-node-${count.index + 1}"
  target_node = "pve"
  clone       = "debian-13-template-20250124"
  
  cores  = 2
  memory = 2048
  agent  = 1
  
  # IPs : 192.168.1.101, .102, .103
  ipconfig0 = "ip=192.168.1.${100 + count.index + 1}/24,gw=192.168.1.1"
  
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

# Afficher les IPs créées
output "cluster_ips" {
  value = [for vm in proxmox_vm_qemu.debian_cluster : vm.ipconfig0]
}
```

### 3️⃣ VM avec Plusieurs Interfaces

```hcl
resource "proxmox_vm_qemu" "debian_multi_nic" {
  name        = "debian-gateway"
  target_node = "pve"
  clone       = "debian-13-template-20250124"
  
  cores  = 2
  memory = 2048
  agent  = 1
  
  # Interface 1 - LAN
  ipconfig0 = "ip=192.168.1.100/24,gw=192.168.1.1"
  
  # Interface 2 - DMZ
  ipconfig1 = "ip=10.0.0.100/24"
  
  nameserver = "192.168.1.1 8.8.8.8"
  
  disk {
    size    = "20G"
    type    = "scsi"
    storage = "local-lvm"
  }
  
  # Réseau LAN
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Réseau DMZ
  network {
    model  = "virtio"
    bridge = "vmbr1"
  }
  
  os_type = "cloud-init"
  ciuser  = "user"
  sshkeys = file("~/.ssh/id_rsa.pub")
}
```

### 4️⃣ Module Réutilisable

**Créer `modules/debian-vm/main.tf` :**

```hcl
variable "vm_name" { type = string }
variable "vm_ip" { type = string }
variable "vm_gateway" { type = string }
variable "template_name" { type = string }

resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  target_node = "pve"
  clone       = var.template_name
  
  cores  = 2
  memory = 2048
  agent  = 1
  
  ipconfig0 = "ip=${var.vm_ip},gw=${var.vm_gateway}"
  
  nameserver = var.vm_gateway
  
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

output "ip" { value = var.vm_ip }
```

**Utiliser le module :**

```hcl
module "web_server" {
  source = "./modules/debian-vm"
  
  vm_name       = "debian-web-01"
  vm_ip         = "192.168.1.101/24"
  vm_gateway    = "192.168.1.1"
  template_name = "debian-13-template-20250124"
}

module "db_server" {
  source = "./modules/debian-vm"
  
  vm_name       = "debian-db-01"
  vm_ip         = "192.168.1.102/24"
  vm_gateway    = "192.168.1.1"
  template_name = "debian-13-template-20250124"
}
```

## Dépannage

### La VM ne démarre pas avec la bonne IP

**1. Vérifier sur la VM :**
```bash
ssh user@192.168.1.100

# Voir la configuration IP
ip addr show

# Voir les logs Cloud-Init
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log
```

**2. Réinitialiser Cloud-Init :**
```bash
sudo cloud-init clean --logs
sudo reboot
```

**3. Vérifier dans Proxmox :**
```bash
# Voir la config Cloud-Init
qm cloudinit dump <vmid> network
qm cloudinit dump <vmid> user

# Régénérer l'image Cloud-Init
qm cloudinit update <vmid>
```

### Pas de connectivité Internet

**Vérifier la configuration :**
```bash
# Gateway correcte ?
ip route show

# DNS configuré ?
cat /etc/resolv.conf

# Test de connectivité
ping -c 4 192.168.1.1  # Gateway
ping -c 4 8.8.8.8      # Internet
nslookup google.com    # DNS
```

**Solution courante :**
```hcl
# Ajouter plusieurs serveurs DNS
nameserver = "192.168.1.1 8.8.8.8 8.8.4.4"
```

### Erreur Terraform

**Erreur : "Connection refused"**
```bash
# Vérifier l'API Proxmox
curl -k https://proxmox.local:8006/api2/json/version

# Vérifier le token
pveum user token list terraform@pve
```

**Erreur : "Template not found"**
```bash
# Lister les templates
qm list | grep template

# Vérifier le nom exact du template
qm config <template_id> | grep name
```

## Commandes Utiles

### Terraform

```bash
# Initialiser
terraform init

# Valider
terraform validate

# Planifier
terraform plan

# Appliquer
terraform apply -auto-approve

# Détruire
terraform destroy

# Voir l'état
terraform show

# Lister les ressources
terraform state list

# Afficher les outputs
terraform output
```

### Proxmox CLI

```bash
# Lister les VMs
qm list

# Voir la config d'une VM
qm config <vmid>

# Démarrer une VM
qm start <vmid>

# Arrêter une VM
qm stop <vmid>

# Voir la config Cloud-Init
qm cloudinit dump <vmid> all

# Régénérer Cloud-Init
qm cloudinit update <vmid>
```

### Diagnostic Réseau

```bash
# Sur la VM
ip addr show                    # IPs configurées
ip route show                   # Routes
ip link show                    # Interfaces
cat /etc/resolv.conf           # DNS
systemctl status networking    # État du réseau
journalctl -u cloud-init       # Logs Cloud-Init
```

## Variables Terraform

### Fichier `terraform.tfvars`

```hcl
# Proxmox
proxmox_api_url    = "https://proxmox.local:8006/api2/json"
proxmox_token_id   = "terraform@pve!terraform-token"
proxmox_node       = "pve"

# Réseau
network_gateway    = "192.168.1.1"
network_dns        = "192.168.1.1 8.8.8.8"

# Template
template_name      = "debian-13-template-20250124"
```

### Variables Sensibles

```bash
# Ne jamais commiter les secrets !
# Utiliser des variables d'environnement

export TF_VAR_proxmox_token_secret="votre-secret-token"
export TF_VAR_ssh_password="VotreMotDePasse"

terraform apply
```

## Ressources

### Documentation

- 📖 [QUICKSTART.md](QUICKSTART.md) - Guide de démarrage rapide
- 📖 [TERRAFORM-STATIC-IPS.md](TERRAFORM-STATIC-IPS.md) - Guide complet (anglais)
- 📖 [README.md](README.md) - Documentation principale

### Liens Externes

- [Proxmox Cloud-Init](https://pve.proxmox.com/wiki/Cloud-Init_Support)
- [Telmate Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## 🎯 Prochaines Étapes

1. ✅ Reconstruire le template : `make build`
2. ✅ Créer un fichier Terraform de test
3. ✅ Déployer une VM avec IP statique
4. ✅ Automatiser avec des modules

---

**Configuration réseau automatisée avec Terraform et Proxmox VE**
