# Configuration des IPs Statiques avec Terraform

Ce guide explique comment utiliser le template Debian 13 créé avec Packer pour déployer des VMs avec des **IPs statiques** via Terraform.

## 🔧 Configuration du Template

Le template est automatiquement configuré pour supporter les IPs statiques :

- ✅ Cloud-Init **network config disabled** dans `files/99-pve.cfg`
- ✅ Configuration réseau gérée par **Proxmox/Terraform**
- ✅ Outils réseau installés (`ifupdown`, `iproute2`, etc.)
- ✅ Documentation embarquée dans `/root/NETWORK-CONFIG-INFO.txt`

## 📋 Prérequis

### Provider Terraform Proxmox

Deux providers sont disponibles pour Terraform :

#### 1. Telmate Provider (Recommandé pour IPs statiques)

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
  pm_api_url      = "https://proxmox.local:8006/api2/json"
  pm_api_token_id = "terraform@pve!terraform-token"
  pm_api_token_secret = "your-secret-token"
  pm_tls_insecure = true  # En développement uniquement
}
```

#### 2. bpg/proxmox Provider (Alternative)

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.38"
    }
  }
}
```

## 🚀 Exemples d'Utilisation

### Exemple 1 : VM Simple avec IP Statique

```hcl
resource "proxmox_vm_qemu" "debian_vm" {
  name        = "debian-vm-01"
  target_node = "pve"
  clone       = "debian-13-template-20250124"
  
  # Configuration matérielle
  cores   = 2
  sockets = 1
  memory  = 2048
  agent   = 1  # QEMU Guest Agent
  
  # Configuration réseau avec IP statique
  ipconfig0 = "ip=192.168.1.100/24,gw=192.168.1.1"
  
  # Configuration DNS
  nameserver   = "192.168.1.1 8.8.8.8"
  searchdomain = "local"
  
  # Configuration disque
  disk {
    size    = "20G"
    type    = "scsi"
    storage = "local-lvm"
    cache   = "writethrough"
  }
  
  # Interface réseau
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Cloud-Init
  os_type    = "cloud-init"
  ciuser     = "user"
  cipassword = "SecurePassword123"
  sshkeys    = file("~/.ssh/id_rsa.pub")
}
```

### Exemple 2 : VM avec Multiple IPs

```hcl
resource "proxmox_vm_qemu" "multi_ip_vm" {
  name        = "debian-multi-ip"
  target_node = "pve"
  clone       = "debian-13-template-20250124"
  
  cores  = 2
  memory = 2048
  agent  = 1
  
  # Première interface avec IP statique
  ipconfig0 = "ip=192.168.1.100/24,gw=192.168.1.1"
  
  # Deuxième interface avec IP statique (réseau différent)
  ipconfig1 = "ip=10.0.0.100/24"
  
  nameserver = "192.168.1.1"
  
  disk {
    size    = "20G"
    type    = "scsi"
    storage = "local-lvm"
  }
  
  # Première interface réseau
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Deuxième interface réseau
  network {
    model  = "virtio"
    bridge = "vmbr1"
  }
  
  os_type = "cloud-init"
  ciuser  = "user"
  sshkeys = file("~/.ssh/id_rsa.pub")
}
```

### Exemple 3 : Module Réutilisable

Créer un module Terraform pour déployer facilement des VMs :

**`modules/debian-vm/main.tf`**
```hcl
variable "vm_name" {
  description = "Nom de la VM"
  type        = string
}

variable "vm_ip" {
  description = "IP statique (format: 192.168.1.100/24)"
  type        = string
}

variable "vm_gateway" {
  description = "Gateway"
  type        = string
  default     = "192.168.1.1"
}

variable "target_node" {
  description = "Noeud Proxmox"
  type        = string
  default     = "pve"
}

variable "template_name" {
  description = "Nom du template"
  type        = string
  default     = "debian-13-template"
}

resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  target_node = var.target_node
  clone       = var.template_name
  
  cores  = 2
  memory = 2048
  agent  = 1
  
  ipconfig0 = "ip=${var.vm_ip},gw=${var.vm_gateway}"
  
  nameserver   = var.vm_gateway
  searchdomain = "local"
  
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

output "vm_ip" {
  value = var.vm_ip
}

output "vm_name" {
  value = proxmox_vm_qemu.vm.name
}
```

**Utilisation du module :**
```hcl
module "debian_vm_1" {
  source = "./modules/debian-vm"
  
  vm_name      = "debian-web-01"
  vm_ip        = "192.168.1.101/24"
  vm_gateway   = "192.168.1.1"
  target_node  = "pve"
}

module "debian_vm_2" {
  source = "./modules/debian-vm"
  
  vm_name      = "debian-db-01"
  vm_ip        = "192.168.1.102/24"
  vm_gateway   = "192.168.1.1"
  target_node  = "pve"
}
```

### Exemple 4 : Cluster de VMs avec IPs Séquentielles

```hcl
locals {
  vm_count = 3
  base_ip  = "192.168.1"
  start_ip = 100
}

resource "proxmox_vm_qemu" "cluster" {
  count = local.vm_count
  
  name        = "debian-cluster-${count.index + 1}"
  target_node = "pve"
  clone       = "debian-13-template-20250124"
  
  cores  = 2
  memory = 2048
  agent  = 1
  
  # Génération d'IPs séquentielles : 192.168.1.100, .101, .102
  ipconfig0 = "ip=${local.base_ip}.${local.start_ip + count.index}/24,gw=${local.base_ip}.1"
  
  nameserver = "${local.base_ip}.1"
  
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

output "cluster_ips" {
  value = [for i in range(local.vm_count) : "${local.base_ip}.${local.start_ip + i}"]
}
```

## 🔍 Vérification et Troubleshooting

### Après le Déploiement

```bash
# Se connecter à la VM
ssh user@192.168.1.100

# Vérifier la configuration IP
ip addr show

# Vérifier la gateway
ip route show

# Vérifier la configuration réseau
cat /etc/network/interfaces

# Vérifier les logs Cloud-Init
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log

# Vérifier la configuration DNS
cat /etc/resolv.conf

# Tester la connectivité
ping -c 4 192.168.1.1  # Gateway
ping -c 4 8.8.8.8      # Internet
```

### Problèmes Courants

#### 1. VM ne démarre pas avec la bonne IP

**Cause** : Cloud-Init n'a pas appliqué la configuration

**Solution** :
```bash
# Sur la VM, forcer la réinitialisation de Cloud-Init
sudo cloud-init clean --logs
sudo reboot
```

**Vérifier dans Proxmox** :
```bash
# Voir la configuration Cloud-Init de la VM
qm cloudinit dump <vmid> user
qm cloudinit dump <vmid> network
```

#### 2. Pas de connectivité réseau

**Causes possibles** :
- Gateway incorrecte
- VLAN mal configuré
- Pare-feu Proxmox

**Vérification** :
```bash
# Sur la VM
ip route show  # Vérifier la route par défaut
ip link show   # Vérifier l'interface

# Sur Proxmox
iptables -L -v -n  # Vérifier les règles firewall
```

#### 3. DNS ne fonctionne pas

**Solution** :
```hcl
# Dans Terraform, spécifier plusieurs serveurs DNS
nameserver = "192.168.1.1 8.8.8.8 8.8.4.4"
```

## 📊 Variables d'Environnement pour Terraform

Créer un fichier `terraform.tfvars` :

```hcl
# Connexion Proxmox
proxmox_api_url          = "https://proxmox.local:8006/api2/json"
proxmox_api_token_id     = "terraform@pve!terraform-token"
proxmox_api_token_secret = "your-secret-token"

# Configuration réseau
network_gateway = "192.168.1.1"
network_subnet  = "192.168.1.0/24"
dns_servers     = "192.168.1.1 8.8.8.8"

# Template
template_name = "debian-13-template-20250124"
target_node   = "pve"
```

## 🔐 Sécurité

### Bonnes Pratiques

1. **Utiliser des tokens API** plutôt que des mots de passe
2. **Stocker les secrets** dans un vault (HashiCorp Vault, etc.)
3. **Ne jamais commiter** `terraform.tfvars` avec des secrets
4. **Utiliser SSH keys** pour l'authentification
5. **Changer les mots de passe** par défaut après déploiement

### Exemple avec variables d'environnement

```bash
# Exporter les variables sensibles
export TF_VAR_proxmox_api_token_secret="your-secret-token"
export TF_VAR_vm_password="SecurePassword123"

# Lancer Terraform
terraform plan
terraform apply
```

## 📚 Ressources Additionnelles

- [Telmate Proxmox Provider Documentation](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Proxmox Cloud-Init Documentation](https://pve.proxmox.com/wiki/Cloud-Init_Support)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## 💡 Exemples Avancés

Voir le projet `tf-proxmox-vm` dans le workspace pour des exemples complets de déploiement avec Terraform et IPs statiques.

---

**Configuration réseau automatisée et sécurisée avec Terraform et Proxmox.**
