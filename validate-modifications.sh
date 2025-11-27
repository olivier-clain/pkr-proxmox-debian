#!/bin/bash
# Script de validation des modifications pour IPs statiques
# Ce script vérifie que toutes les modifications nécessaires ont été appliquées

set -e

echo "════════════════════════════════════════════════════════════════════════════"
echo "  Validation des Modifications - Support des IPs Statiques avec Terraform"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

ERRORS=0
WARNINGS=0

# Fonction pour vérifier l'existence d'un fichier
check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        echo "✅ $description : $file"
    else
        echo "❌ ERREUR: $description manquant : $file"
        ((ERRORS++))
    fi
}

# Fonction pour vérifier le contenu d'un fichier
check_content() {
    local file=$1
    local pattern=$2
    local description=$3
    
    if [ ! -f "$file" ]; then
        echo "❌ ERREUR: Fichier introuvable : $file"
        ((ERRORS++))
        return
    fi
    
    if grep -q "$pattern" "$file"; then
        echo "✅ $description présent dans $file"
    else
        echo "⚠️  AVERTISSEMENT: $description manquant dans $file"
        ((WARNINGS++))
    fi
}

echo "1️⃣  Vérification des fichiers de configuration"
echo "────────────────────────────────────────────────────────────────────────────"

# Fichiers principaux
check_file "debian-13.pkr.hcl" "Fichier de configuration Packer principal"
check_file "variables.pkr.hcl" "Fichier de variables"
check_file "variables.auto.pkrvars.hcl" "Fichier de valeurs par défaut"
check_file "packer.pkr.hcl" "Fichier de configuration Packer"

# Fichiers Cloud-Init
check_file "files/99-pve.cfg" "Configuration Cloud-Init Proxmox"

# Scripts
check_file "scripts/01-update-system.sh" "Script de mise à jour système"
check_file "scripts/02-install-packages.sh" "Script d'installation de paquets"
check_file "scripts/03-configure-ssh.sh" "Script de configuration SSH"
check_file "scripts/04-configure-cloud-init.sh" "Script de configuration Cloud-Init"
check_file "scripts/05-configure-network.sh" "Script de configuration réseau (NOUVEAU)"
check_file "scripts/99-cleanup.sh" "Script de nettoyage"

# Documentation
check_file "README.md" "Documentation principale"
check_file "TERRAFORM-STATIC-IPS.md" "Guide Terraform (NOUVEAU)"
check_file "QUICKSTART.md" "Guide de démarrage rapide (NOUVEAU)"
check_file "STATIC-IP-MODIFICATIONS.md" "Résumé des modifications (NOUVEAU)"
check_file "CHANGELOG.md" "Historique des changements"
check_file "scripts/README.md" "Documentation des scripts"

# Multi-hypervisor
check_file "multi/debian-13-multi.pkr.hcl" "Configuration multi-hypervisor"

echo ""
echo "2️⃣  Vérification du contenu des fichiers modifiés"
echo "────────────────────────────────────────────────────────────────────────────"

# Vérifier que 99-pve.cfg a la désactivation réseau
check_content "files/99-pve.cfg" "network:" "Désactivation de la gestion réseau Cloud-Init"
check_content "files/99-pve.cfg" "config: disabled" "Configuration réseau désactivée"

# Vérifier que debian-13.pkr.hcl inclut le nouveau script
check_content "debian-13.pkr.hcl" "05-configure-network.sh" "Provisioner du script réseau"

# Vérifier que multi inclut aussi le script
check_content "multi/debian-13-multi.pkr.hcl" "05-configure-network.sh" "Provisioner du script réseau (multi)"

# Vérifier que le script réseau existe et est exécutable
if [ -f "scripts/05-configure-network.sh" ]; then
    if [ -x "scripts/05-configure-network.sh" ]; then
        echo "✅ Script 05-configure-network.sh est exécutable"
    else
        echo "⚠️  AVERTISSEMENT: Script 05-configure-network.sh n'est pas exécutable"
        echo "    Exécutez: chmod +x scripts/05-configure-network.sh"
        ((WARNINGS++))
    fi
fi

# Vérifier que le README mentionne les IPs statiques
check_content "README.md" "Static IP" "Mention des IPs statiques dans le README"
check_content "README.md" "TERRAFORM-STATIC-IPS.md" "Référence au guide Terraform"
check_content "README.md" "QUICKSTART.md" "Référence au guide de démarrage rapide"

# Vérifier le CHANGELOG
check_content "CHANGELOG.md" "Static IP" "Entrée dans le CHANGELOG"
check_content "CHANGELOG.md" "05-configure-network.sh" "Mention du nouveau script dans le CHANGELOG"

echo ""
echo "3️⃣  Vérification de la structure des scripts"
echo "────────────────────────────────────────────────────────────────────────────"

# Vérifier que les scripts ont le shebang correct
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        if head -n 1 "$script" | grep -q "^#!/bin/bash"; then
            echo "✅ Shebang correct: $script"
        else
            echo "❌ ERREUR: Shebang manquant ou incorrect dans $script"
            ((ERRORS++))
        fi
    fi
done

echo ""
echo "4️⃣  Vérification de la documentation"
echo "────────────────────────────────────────────────────────────────────────────"

# Vérifier que TERRAFORM-STATIC-IPS.md contient des exemples
if [ -f "TERRAFORM-STATIC-IPS.md" ]; then
    examples=0
    grep -c "^### Exemple" "TERRAFORM-STATIC-IPS.md" > /dev/null && examples=$(grep -c "^### Exemple" "TERRAFORM-STATIC-IPS.md")
    if [ "$examples" -ge 3 ]; then
        echo "✅ TERRAFORM-STATIC-IPS.md contient $examples exemples"
    else
        echo "⚠️  AVERTISSEMENT: TERRAFORM-STATIC-IPS.md contient seulement $examples exemples"
        ((WARNINGS++))
    fi
fi

echo ""
echo "5️⃣  Résumé"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ ✅ ✅ TOUTES LES VÉRIFICATIONS SONT PASSÉES ! ✅ ✅ ✅"
    echo ""
    echo "Le projet est prêt pour supporter les IPs statiques avec Terraform !"
    echo ""
    echo "Prochaines étapes :"
    echo "  1. Reconstruire le template : make build"
    echo "  2. Lire le guide Terraform : cat TERRAFORM-STATIC-IPS.md"
    echo "  3. Déployer une VM de test avec IP statique"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  VALIDATION AVEC AVERTISSEMENTS"
    echo ""
    echo "Erreurs critiques : 0"
    echo "Avertissements    : $WARNINGS"
    echo ""
    echo "Le projet devrait fonctionner, mais certains éléments méritent attention."
    echo "Consultez les avertissements ci-dessus."
    echo ""
    exit 0
else
    echo "❌ VALIDATION ÉCHOUÉE"
    echo ""
    echo "Erreurs critiques : $ERRORS"
    echo "Avertissements    : $WARNINGS"
    echo ""
    echo "Corrigez les erreurs avant de continuer."
    echo ""
    exit 1
fi
