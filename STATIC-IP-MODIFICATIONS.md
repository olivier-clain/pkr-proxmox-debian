# Modifications pour Support des IPs Statiques avec Terraform

## 🎯 Objectif

Permettre l'utilisation d'**IPs statiques** avec Terraform/Proxmox en désactivant la gestion automatique du réseau par Cloud-Init.

## 📝 Modifications Effectuées

### 1. Configuration Cloud-Init (`files/99-pve.cfg`)

**Ajout** : Désactivation de la gestion réseau par Cloud-Init

```yaml
# Disable automatic network configuration
# This allows Proxmox/Terraform to manage network configuration
# including static IPs via Proxmox API
network:
  config: disabled
```

**Impact** : Proxmox/Terraform peut maintenant gérer entièrement la configuration réseau via l'API.

---

### 2. Script Cloud-Init (`scripts/04-configure-cloud-init.sh`)

**Modification** : Mise à jour du commentaire pour clarifier la stratégie réseau

```bash
# Gestionnaire de réseau - Network config is disabled in 99-pve.cfg
# This allows Proxmox/Terraform to manage static IPs
```

**Impact** : Documentation claire pour les futurs mainteneurs.

---

### 3. Nouveau Script Réseau (`scripts/05-configure-network.sh`)

**Création** : Script complet de préparation réseau

**Fonctionnalités** :
- Installation des outils réseau (ifupdown, iproute2, bridge-utils)
- Configuration de base de `/etc/network/interfaces`
- Désactivation de NetworkManager et systemd-networkd
- Nettoyage des configurations DHCP persistantes
- Création d'une documentation embarquée (`/root/NETWORK-CONFIG-INFO.txt`)

**Impact** : Le template est prêt à recevoir des configurations réseau statiques.

---

### 4. Configuration Packer (`debian-13.pkr.hcl`)

**Ajout** : Intégration du nouveau script dans le build

```hcl
# Script 5: Network configuration for static IPs
provisioner "shell" {
  execute_command = "echo '${var.ssh_password}' | sudo -S -E bash '{{ .Path }}'"
  scripts = [
    "${local.scripts_dir}/05-configure-network.sh"
  ]
}
```

**Impact** : Le script s'exécute automatiquement lors de la création du template.

---

### 5. Documentation

#### README.md

**Ajout** : Section complète "Using with Terraform and Static IPs"
- Exemple Terraform de base
- Configuration via interface Proxmox
- Commandes de vérification
- Référence au guide complet

#### TERRAFORM-STATIC-IPS.md (nouveau)

**Création** : Guide complet et détaillé
- Configuration du provider Terraform
- 4 exemples d'utilisation (simple, multi-IP, module, cluster)
- Section troubleshooting complète
- Bonnes pratiques de sécurité
- Variables d'environnement

#### scripts/README.md

**Ajout** : Documentation du nouveau script `05-configure-network.sh`

#### CHANGELOG.md

**Ajout** : Entrée détaillée des modifications dans la section [Unreleased]

---

## 🚀 Utilisation

### Étape 1 : Reconstruire le Template

```bash
cd /home/user/workspace/pkr-proxmox-debian

# Charger les variables d'environnement
source .env

# Construire le nouveau template
make build
```

### Étape 2 : Déployer avec Terraform

```hcl
resource "proxmox_vm_qemu" "debian_vm" {
  name        = "debian-vm-01"
  target_node = "pve"
  clone       = "debian-13-template-YYYYMMDD"  # Votre nouveau template
  
  cores  = 2
  memory = 2048
  agent  = 1
  
  # Configuration IP statique
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

### Étape 3 : Vérifier

```bash
# Après déploiement, se connecter à la VM
ssh user@192.168.1.100

# Vérifier l'IP
ip addr show

# Vérifier la gateway
ip route show

# Lire la documentation embarquée
cat /root/NETWORK-CONFIG-INFO.txt
```

---

## ✅ Résultat

Le template Debian 13 est maintenant :
- ✅ **Compatible avec Terraform** pour IPs statiques
- ✅ **Géré par Proxmox** pour la configuration réseau
- ✅ **Documenté complètement** avec exemples
- ✅ **Prêt pour production** avec bonnes pratiques

---

## 📁 Fichiers Modifiés

```
pkr-proxmox-debian/
├── debian-13.pkr.hcl                  [MODIFIÉ]  - Ajout provisioner script 05
├── files/
│   └── 99-pve.cfg                     [MODIFIÉ]  - Désactivation network config
├── scripts/
│   ├── 04-configure-cloud-init.sh     [MODIFIÉ]  - Mise à jour commentaires
│   ├── 05-configure-network.sh        [NOUVEAU]  - Configuration réseau
│   └── README.md                      [MODIFIÉ]  - Documentation script 05
├── CHANGELOG.md                       [MODIFIÉ]  - Ajout entrée [Unreleased]
├── README.md                          [MODIFIÉ]  - Section Terraform + IPs statiques
├── TERRAFORM-STATIC-IPS.md            [NOUVEAU]  - Guide complet Terraform
└── STATIC-IP-MODIFICATIONS.md         [NOUVEAU]  - Ce fichier
```

---

## 🔍 Compatibilité

### Versions Testées
- ✅ Packer >= 1.9.0
- ✅ Proxmox VE >= 7.0
- ✅ Terraform >= 1.0
- ✅ Debian 13.2.0

### Providers Terraform Compatibles
- ✅ `telmate/proxmox` (recommandé)
- ✅ `bpg/proxmox`

---

## 🆘 Support

Pour des questions ou problèmes :
1. Consulter `TERRAFORM-STATIC-IPS.md` (guide complet)
2. Vérifier `/root/NETWORK-CONFIG-INFO.txt` sur la VM
3. Consulter les logs Cloud-Init : `/var/log/cloud-init.log`

---

**Date de modification** : 24 novembre 2025
**Version** : 1.1.0-unreleased
**Auteur** : Configuration automatique pour IPs statiques
