# Provisioning Scripts

This directory contains the Bash scripts used by Packer to configure the Debian 13 template.

## 📋 Scripts List

### 01-update-system.sh
**Description**: Updates all Debian system packages
- Update package list (\`apt-get update\`)
- Upgrade installed packages (\`apt-get upgrade\`)
- Full system upgrade (\`apt-get dist-upgrade\`)

**When to modify**: If you want to change the update strategy

---

### 02-install-packages.sh
**Description**: Installs essential packages for the template
- System tools: curl, wget, vim, htop, net-tools
- SSH and certificates
- QEMU Guest Agent (required for Proxmox)
- Cloud-Init
- Optional development tools

**When to modify**: To add/remove packages according to your needs

**Customization**:
\`\`\`bash
PACKAGES=(
    "your-package-1"
    "your-package-2"
    # ...
)
\`\`\`

---

### 03-configure-ssh.sh
**Description**: Configures SSH server securely
- Disables root password authentication
- Enables public key authentication
- Disables dangerous authentications
- Optimizes security parameters

**When to modify**: To adjust SSH security parameters

---

### 04-configure-cloud-init.sh
**Description**: Configures Cloud-Init for Proxmox
- Installs Proxmox configuration (99-pve.cfg)
- Configures Cloud-Init modules
- Prepares template for automated deployment

**When to modify**: To customize Cloud-Init behavior

---

### 99-cleanup.sh
**Description**: Cleans template before finalization
- Removes SSH host keys (will be regenerated)
- Resets machine identifiers
- Cleans all logs
- Cleans APT and system caches
- Removes history and temporary files

**When to modify**: To add custom cleanup steps

**⚠️ Important**: This script must always run last!

---

## 🔧 Best Practices

### Execution Order
Scripts are numbered to indicate their execution order:
1. \`01-*\`: System preparation
2. \`02-*\`: Installation
3. \`03-*\`: Configuration
4. \`04-*\`: Advanced configuration
5. \`99-*\`: Final cleanup

### Writing New Scripts

**Basic template**:
\`\`\`bash
#!/bin/bash
# Script XX: Script title
# Description: Detailed description

set -euo pipefail

echo "==> Starting operation..."

# Your code here

echo "==> Operation completed"
\`\`\`

**Rules**:
- Always use \`set -euo pipefail\` to stop on error
- Add \`echo "==> ..."\` messages for tracking
- Test script individually before integration
- Document changes in this README

### Make Scripts Executable
\`\`\`bash
chmod +x scripts/*.sh
\`\`\`

### Test a Script Individually
\`\`\`bash
# On a test VM
sudo bash scripts/01-update-system.sh
\`\`\`

---

## 🚀 Adding a New Script

1. **Create the file**:
   \`\`\`bash
   touch scripts/05-my-script.sh
   chmod +x scripts/05-my-script.sh
   \`\`\`

2. **Write the script** following the template

3. **Add to \`debian-13.pkr.hcl\`**:
   \`\`\`hcl
   provisioner "shell" {
     execute_command = "echo '\${var.ssh_password}' | sudo -S -E bash '{{ .Path }}'"
     scripts = [
       "\${local.scripts_dir}/05-my-script.sh"
     ]
   }
   \`\`\`

4. **Test**:
   \`\`\`bash
   make validate
   make build
   \`\`\`

---

## 🐛 Debugging

### View execution logs
\`\`\`bash
# Build with detailed logs
make build-debug
\`\`\`

### Test a script in isolation
\`\`\`bash
# Launch a Debian 13 VM
# Copy the script
# Execute manually
sudo bash /path/to/script.sh
\`\`\`

### Check syntax
\`\`\`bash
bash -n scripts/01-update-system.sh
shellcheck scripts/*.sh  # If shellcheck is installed
\`\`\`

---

## 📝 Available Variables

In scripts, you can use:
- \`$DEBIAN_FRONTEND=noninteractive\`: Already set for apt
- All standard environment variables
- Root access via sudo (password provided by Packer)

---

## 🔒 Security

- Scripts execute with sudo privileges
- SSH password is transmitted securely by Packer
- Avoid storing secrets in scripts
- Use variables for sensitive data

---

**Last updated**: 2025-11-19
