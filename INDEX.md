# 📚 Index de la Documentation

> Navigation rapide dans toute la documentation du projet

## 🚀 Pour Commencer

| Document | Description | Niveau |
|----------|-------------|--------|
| **[QUICKSTART.md](QUICKSTART.md)** | Guide de démarrage rapide (étape par étape) | ⭐ Débutant |
| **[README.md](README.md)** | Documentation principale du projet | ⭐⭐ Intermédiaire |
| **[MODIFICATIONS-COMPLETE.md](MODIFICATIONS-COMPLETE.md)** | Résumé des modifications effectuées | ⭐ Débutant |

## 🌐 Terraform et IPs Statiques

| Document | Description | Langue |
|----------|-------------|--------|
| **[TERRAFORM-STATIC-IPS.md](TERRAFORM-STATIC-IPS.md)** | Guide complet Terraform (5 exemples) | 🇬🇧 Anglais |
| **[TERRAFORM-GUIDE-FR.md](TERRAFORM-GUIDE-FR.md)** | Guide complet Terraform (4 exemples) | 🇫🇷 Français |
| **[STATIC-IP-MODIFICATIONS.md](STATIC-IP-MODIFICATIONS.md)** | Détails techniques des modifications | 🇬🇧 Anglais |

## 🔧 Configuration et Utilisation

| Document | Description |
|----------|-------------|
| **[README.md](README.md)** | Configuration complète de Packer |
| **[README.fr.md](README.fr.md)** | Documentation française |
| **[MULTI-HYPERVISOR.md](MULTI-HYPERVISOR.md)** | Déploiement multi-hyperviseur |
| **[scripts/README.md](scripts/README.md)** | Documentation des scripts de provisioning |

## 📖 Guides Avancés

| Document | Description |
|----------|-------------|
| **[BEST-PRACTICES.md](BEST-PRACTICES.md)** | Bonnes pratiques Packer et Proxmox |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | Guide de contribution |
| **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** | Vue d'ensemble du projet |
| **[IMPROVEMENTS.md](IMPROVEMENTS.md)** | Améliorations futures |

## 📝 Historique et Modifications

| Document | Description |
|----------|-------------|
| **[CHANGELOG.md](CHANGELOG.md)** | Historique des versions |
| **[MODIFICATIONS-COMPLETE.md](MODIFICATIONS-COMPLETE.md)** | Résumé des modifications récentes |
| **[STATIC-IP-MODIFICATIONS.md](STATIC-IP-MODIFICATIONS.md)** | Détails techniques IPs statiques |

## 🛠️ Outils et Scripts

| Fichier | Description |
|---------|-------------|
| **[Makefile](Makefile)** | Automatisation des commandes |
| **[validate-modifications.sh](validate-modifications.sh)** | Validation des modifications |
| **[scripts/](scripts/)** | Scripts de provisioning |

## 📋 Par Cas d'Usage

### Je débute avec ce projet
1. Lire [QUICKSTART.md](QUICKSTART.md)
2. Suivre les étapes pas à pas
3. Construire le premier template

### Je veux déployer avec Terraform
1. Lire [TERRAFORM-GUIDE-FR.md](TERRAFORM-GUIDE-FR.md) 🇫🇷
2. Ou [TERRAFORM-STATIC-IPS.md](TERRAFORM-STATIC-IPS.md) 🇬🇧
3. Utiliser les exemples fournis

### Je veux comprendre les modifications
1. Lire [MODIFICATIONS-COMPLETE.md](MODIFICATIONS-COMPLETE.md)
2. Consulter [STATIC-IP-MODIFICATIONS.md](STATIC-IP-MODIFICATIONS.md)
3. Vérifier avec `./validate-modifications.sh`

### Je veux personnaliser le template
1. Lire [README.md](README.md) section "Customization"
2. Consulter [scripts/README.md](scripts/README.md)
3. Modifier les scripts dans `scripts/`

### J'ai un problème
1. Section "Troubleshooting" du [README.md](README.md)
2. Section "Dépannage" de [TERRAFORM-GUIDE-FR.md](TERRAFORM-GUIDE-FR.md)
3. Consulter les logs Cloud-Init sur la VM

### Je veux déployer sur plusieurs hyperviseurs
1. Lire [MULTI-HYPERVISOR.md](MULTI-HYPERVISOR.md)
2. Configurer les variables pour chaque hyperviseur
3. Lancer `make build-multi`

## 🔍 Recherche Rapide

### Configuration Packer
- Variables : `variables.pkr.hcl`
- Valeurs par défaut : `variables.auto.pkrvars.hcl`
- Configuration principale : `debian-13.pkr.hcl`
- Plugins : `packer.pkr.hcl`

### Scripts de Provisioning
- `scripts/01-update-system.sh` - Mise à jour système
- `scripts/02-install-packages.sh` - Installation paquets
- `scripts/03-configure-ssh.sh` - Configuration SSH
- `scripts/04-configure-cloud-init.sh` - Configuration Cloud-Init
- `scripts/05-configure-network.sh` - Configuration réseau (IPs statiques)
- `scripts/99-cleanup.sh` - Nettoyage final

### Fichiers Cloud-Init
- `files/99-pve.cfg` - Configuration Proxmox Cloud-Init
- `http/preseed.cfg` - Configuration installation Debian

### Exemples Terraform
- VM simple : [TERRAFORM-STATIC-IPS.md](TERRAFORM-STATIC-IPS.md#exemple-1-vm-simple)
- Multi-IP : [TERRAFORM-STATIC-IPS.md](TERRAFORM-STATIC-IPS.md#exemple-2-vm-avec-multiple-ips)
- Module : [TERRAFORM-STATIC-IPS.md](TERRAFORM-STATIC-IPS.md#exemple-3-module-réutilisable)
- Cluster : [TERRAFORM-STATIC-IPS.md](TERRAFORM-STATIC-IPS.md#exemple-4-cluster)

## 📊 Documents par Taille

| Petit (<2KB) | Moyen (2-5KB) | Grand (>5KB) |
|--------------|---------------|--------------|
| 99-pve.cfg | validate-modifications.sh | TERRAFORM-STATIC-IPS.md |
| LICENSE | scripts/*.sh | QUICKSTART.md |
| .gitignore | STATIC-IP-MODIFICATIONS.md | README.md |
| | MODIFICATIONS-COMPLETE.md | TERRAFORM-GUIDE-FR.md |

## 🎯 Checklist de Démarrage

- [ ] Lire [QUICKSTART.md](QUICKSTART.md)
- [ ] Configurer `.env`
- [ ] Exécuter `make init`
- [ ] Exécuter `make build`
- [ ] Lire [TERRAFORM-GUIDE-FR.md](TERRAFORM-GUIDE-FR.md)
- [ ] Créer un fichier Terraform de test
- [ ] Déployer une première VM
- [ ] Vérifier avec SSH

## 📞 Aide et Support

### Avant de Poser une Question
1. ✅ Consulter la section troubleshooting du README
2. ✅ Vérifier les logs Cloud-Init
3. ✅ Exécuter `./validate-modifications.sh`
4. ✅ Lire les documents pertinents ci-dessus

### Commandes Utiles
```bash
# Valider le projet
./validate-modifications.sh

# Aide Makefile
make help

# Logs détaillés
make build-debug

# Voir la config d'une VM
qm config <vmid>
```

## 🔗 Liens Rapides

- [Proxmox Documentation](https://pve.proxmox.com/wiki/Main_Page)
- [Cloud-Init Docs](https://cloudinit.readthedocs.io/)
- [Packer Docs](https://www.packer.io/docs)
- [Terraform Docs](https://www.terraform.io/docs)

---

**📚 Navigation documentaire complète pour le projet pkr-proxmox-debian**

*Dernière mise à jour : 24 novembre 2025*
