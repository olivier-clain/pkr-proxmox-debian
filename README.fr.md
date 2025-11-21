# Packer Template Proxmox Debian 13

> 🇫🇷 Version française | 🇬🇧 [English version](README.md)

Template Packer automatisé pour créer des images Debian 13 sur Proxmox VE avec :
- Utilisateur par défaut : `user` / (mot de passe configurable)
- SSH activé, sudo sans mot de passe, QEMU guest agent
- Installation automatisée via preseed
- Support UEFI
- Configuration optimisée pour Proxmox

## 📋 Prérequis

### Sur Proxmox
- Proxmox VE 7.0+
- Token API avec privilèges suffisants (VM.Allocate, VM.Config, Datastore.AllocateSpace)
- ISO Debian 13 téléchargée dans le storage Proxmox
- Stockage disponible pour le template

### En local
- Packer >= 1.9.0
- Accès réseau au serveur Proxmox

## 🔐 Configuration Sécurisée

### 1. Créer un token API Proxmox

```bash
# Sur Proxmox, créer un utilisateur dédié
pveum user add packer@pve
pveum aclmod / -user packer@pve -role PVEVMAdmin

# Créer un token API
pveum user token add packer@pve packer-token --privsep=0
# Sauvegarder le token secret affiché
```

### 2. Configurer les variables d'environnement

```bash
# Copier le template
cp .env.example .env

# Éditer .env avec vos vraies valeurs
# NE JAMAIS COMMITER CE FICHIER !
nano .env
```

### 3. Télécharger l'ISO Debian

```bash
# Sur Proxmox, télécharger l'ISO
cd /var/lib/vz/template/iso
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.2.0-amd64-netinst.iso

# Vérifier que l'ISO est visible dans Proxmox
```

## 🚀 Utilisation

### Démarrage Rapide (Hyperviseur Unique)

```bash
# Charger les variables d'environnement
source .env

# Initialiser Packer (première fois uniquement)
make init

# Builder le template
make build
```

Le template sera créé dans Proxmox avec l'ID 9988 (configurable) et le nom `debian-13-template-YYYYMMDD`.

### Alternative : Utilisation Directe de Packer

```bash
# Charger les variables d'environnement
source .env

# Initialiser Packer
packer init .

# Valider la configuration
packer validate .

# Builder le template
packer build .
```

### Mode Multi-Hyperviseur (Avancé)

Builder des templates sur 3 hyperviseurs Proxmox simultanément :

```bash
# Build sur les 3 hyperviseurs en parallèle
make build-multi

# Ou build sur un hyperviseur spécifique
make build-hv1  # 10.0.0.240
make build-hv2  # 10.0.0.235
make build-hv3  # 10.0.0.245
```

**📖 Voir [MULTI-HYPERVISOR.md](MULTI-HYPERVISOR.md) pour la documentation détaillée du mode multi-hyperviseur.**

### Utilisation du Makefile

```bash
# Afficher toutes les commandes disponibles
make help

# Workflow complet (init + validate + build)
make all

# Build avec logs de debug
make build-debug

# Valider la configuration uniquement
make validate
```

## 🎛️ Personnalisation

### Variables principales

Éditez `variables.pkr.hcl` pour personnaliser :

- `vm_id` : ID du template (défaut: 9988)
- `cpu_cores` : Nombre de cœurs (défaut: 2)
- `memory` : RAM en MB (défaut: 1024)
- `disk_size` : Taille du disque (défaut: 20G)
- `storage_pool` : Pool de stockage (défaut: local-lvm)
- `network_bridge` : Bridge réseau (défaut: vmbr0)

### Personnalisation de l'installation

- **`http/preseed.cfg`** : Configuration Debian (paquets, partitionnement, utilisateurs)
- **`files/99-pve.cfg`** : Configuration Cloud-Init
- **`scripts/`** : Scripts de provisioning modulaires (voir `scripts/README.md`)
  - Modifier les scripts existants pour personnaliser l'installation
  - Ajouter de nouveaux scripts selon vos besoins
- **`variables.auto.pkrvars.hcl`** : Valeurs par défaut (CPU, RAM, disque, etc.)

### Exemples

**Changer le mot de passe utilisateur :**
```bash
export PKR_VAR_ssh_password="MonMotDePasseSecurise"
```

**Utiliser un VLAN spécifique :**
Éditez `variables.pkr.hcl` et définissez `network_vlan = "100"`

**Ajouter des paquets :**
Éditez `scripts/02-install-packages.sh` et ajoutez vos paquets dans le tableau `PACKAGES`.

## 🔧 Troubleshooting

### Le build ne démarre pas
- Vérifiez que les variables d'environnement sont chargées : `echo $PKR_VAR_proxmox_api_url`
- Vérifiez les permissions du token API
- Vérifiez que l'ISO existe : `pvesm list local --content iso`

### Timeout SSH
- Augmentez `ssh_timeout` dans `variables.pkr.hcl`
- Vérifiez les logs de la VM dans Proxmox
- Vérifiez que le preseed s'exécute correctement

### Erreur de boot
- Vérifiez le `boot_command` dans `debian-13.pkr.hcl`
- Testez manuellement l'installation Debian avec les mêmes paramètres
- Vérifiez que le serveur HTTP Packer est accessible depuis la VM

## 📁 Structure du projet

```
.
├── .env.example                # Template de configuration (à copier en .env)
├── .gitignore                  # Exclusion des fichiers sensibles
├── LICENSE                     # Licence MIT
├── Makefile                    # Automatisation des commandes (15+ commandes)
├── README.md                   # Documentation en anglais
├── README.fr.md                # Cette documentation (français)
├── MULTI-HYPERVISOR.md         # Guide du mode multi-hyperviseur
├── CHANGELOG.md                # Historique des versions
├── CONTRIBUTING.md             # Guide de contribution
├── PROJECT_SUMMARY.md          # Résumé du projet
├── packer.pkr.hcl              # Configuration Packer (plugins, locals)
├── debian-13.pkr.hcl           # Configuration build hyperviseur unique
├── variables.pkr.hcl           # Définition des variables
├── variables.auto.pkrvars.hcl  # Valeurs par défaut des variables
├── files/
│   └── 99-pve.cfg              # Configuration Cloud-Init pour Proxmox
├── http/
│   └── preseed.cfg             # Configuration d'installation Debian
├── scripts/
│   ├── README.md               # Documentation des scripts
│   ├── 01-update-system.sh     # Mise à jour du système
│   ├── 02-install-packages.sh  # Installation des paquets
│   ├── 03-configure-ssh.sh     # Configuration SSH sécurisée
│   ├── 04-configure-cloud-init.sh  # Configuration Cloud-Init
│   └── 99-cleanup.sh           # Nettoyage final du template
└── multi/                      # Configuration multi-hyperviseur
    ├── debian-13-multi.pkr.hcl # Build multi-hyperviseur (3 sources)
    ├── variables-multi.pkr.hcl # Variables multi-hyperviseur
    ├── packer.pkr.hcl          # Config Packer (lien symbolique)
    ├── variables.pkr.hcl       # Variables (lien symbolique)
    ├── scripts/ -> ../scripts  # Lien symbolique vers scripts
    ├── files/ -> ../files      # Lien symbolique vers files
    └── http/ -> ../http        # Lien symbolique vers http
```

## ⚠️ Sécurité

- ✅ Ne jamais commiter le fichier `.env` (contient des secrets)
- ✅ Utiliser uniquement des variables d'environnement pour les credentials
- ✅ En production, désactiver `skip_tls_verify = false`
- ✅ Changer le mot de passe par défaut après la création du template
- ✅ Limiter les privilèges du token API au minimum nécessaire

## 📝 Variables d'environnement requises

| Variable | Description | Exemple |
|----------|-------------|---------|
| `PKR_VAR_proxmox_api_url` | URL de l'API Proxmox | `https://proxmox.local:8006/api2/json` |
| `PKR_VAR_proxmox_api_token_id` | ID du token | `packer@pve!packer-token` |
| `PKR_VAR_proxmox_api_token_secret` | Secret du token | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `PKR_VAR_proxmox_node` | Nom du nœud | `pve` |
| `PKR_VAR_ssh_password` | Mot de passe temporaire | `SecurePassword123` |

---

**Infrastructure souveraine, automatisée et sécurisée.**
