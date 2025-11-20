# Packer Template Proxmox Debian 13

> 🇫🇷 [Version française](README.fr.md) | 🇬🇧 English version

Automated Packer template to create Debian 13 images on Proxmox VE with:
- Default user: `user` / (configurable password)
- SSH enabled, passwordless sudo, QEMU guest agent
- Automated installation via preseed
- UEFI support
- Optimized configuration for Proxmox

## 📋 Prerequisites

### On Proxmox
- Proxmox VE 7.0+
- API Token with sufficient privileges (VM.Allocate, VM.Config, Datastore.AllocateSpace)
- Debian 13 ISO downloaded in Proxmox storage
- Available storage for the template

### Locally
- Packer >= 1.9.0
- Network access to Proxmox server

## 🔐 Secure Configuration

### 1. Create a Proxmox API Token

```bash
# On Proxmox, create a dedicated user
pveum user add packer@pve
pveum aclmod / -user packer@pve -role PVEVMAdmin

# Create an API token
pveum user token add packer@pve packer-token --privsep=0
# Save the displayed secret token
```

### 2. Configure Environment Variables

```bash
# Copy the template
cp .env.example .env

# Edit .env with your actual values
# NEVER COMMIT THIS FILE!
nano .env
```

### 3. Download Debian ISO

```bash
# On Proxmox, download the ISO
cd /var/lib/vz/template/iso
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.2.0-amd64-netinst.iso

# Verify that the ISO is visible in Proxmox
```

## 🚀 Usage

### Build the Template

```bash
# Load environment variables
source .env

# Initialize Packer (first time only)
packer init .

# Validate the configuration
packer validate .

# Build the template
packer build .
```

### Result

The template will be created in Proxmox with ID 9012 (configurable) and name `debian-13-template-YYYYMMDD`.

## 🎛️ Customization

### Main Variables

Edit `variables.pkr.hcl` to customize:

- `vm_id`: Template ID (default: 9988)
- `cpu_cores`: Number of cores (default: 2)
- `memory`: RAM in MB (default: 1024)
- `disk_size`: Disk size (default: 20G)
- `storage_pool`: Storage pool (default: local-lvm)
- `network_bridge`: Network bridge (default: vmbr0)

### Installation Customization

- **`http/preseed.cfg`**: Debian configuration (packages, partitioning, users)
- **`files/99-pve.cfg`**: Cloud-Init configuration
- **`scripts/`**: Modular provisioning scripts (see `scripts/README.md`)
  - Modify existing scripts to customize installation
  - Add new scripts as needed
- **`variables.auto.pkrvars.hcl`**: Default values (CPU, RAM, disk, etc.)

### Examples

**Change user password:**
```bash
export PKR_VAR_ssh_password="MySecurePassword"
```

**Use a specific VLAN:**
Edit `variables.pkr.hcl` and set `network_vlan = "100"`

**Add packages:**
Edit `scripts/02-install-packages.sh` and add your packages to the `PACKAGES` array.

## 🔧 Troubleshooting

### Build doesn't start
- Verify environment variables are loaded: `echo $PKR_VAR_proxmox_api_url`
- Check API token permissions
- Verify the ISO exists: `pvesm list local --content iso`

### SSH Timeout
- Increase `ssh_timeout` in `variables.pkr.hcl`
- Check VM logs in Proxmox
- Verify preseed is executing correctly

### Boot Error
- Check the `boot_command` in `debian-13.pkr.hcl`
- Manually test Debian installation with the same parameters
- Verify Packer HTTP server is accessible from the VM

## 📁 Project Structure

```
.
├── .env.example                # Configuration template (copy to .env)
├── .gitignore                  # Exclude sensitive files
├── LICENSE                     # MIT License
├── Makefile                    # Command automation
├── packer.pkr.hcl              # Packer configuration (plugins, locals)
├── debian-13.pkr.hcl           # Debian 13 source and build configuration
├── variables.pkr.hcl           # Variable definitions
├── variables.auto.pkrvars.hcl  # Default variable values
├── README.md                   # This documentation
├── files/
│   └── 99-pve.cfg              # Cloud-Init configuration for Proxmox
├── http/
│   └── preseed.cfg             # Debian installation configuration
└── scripts/
    ├── README.md               # Scripts documentation
    ├── 01-update-system.sh     # System update
    ├── 02-install-packages.sh  # Package installation
    ├── 03-configure-ssh.sh     # Secure SSH configuration
    ├── 04-configure-cloud-init.sh  # Cloud-Init configuration
    └── 99-cleanup.sh           # Final template cleanup
```

## ⚠️ Security

- ✅ Never commit the `.env` file (contains secrets)
- ✅ Only use environment variables for credentials
- ✅ In production, disable `skip_tls_verify = false`
- ✅ Change the default password after template creation
- ✅ Limit API token privileges to minimum necessary

## 📝 Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `PKR_VAR_proxmox_api_url` | Proxmox API URL | `https://proxmox.local:8006/api2/json` |
| `PKR_VAR_proxmox_api_token_id` | Token ID | `packer@pve!packer-token` |
| `PKR_VAR_proxmox_api_token_secret` | Token secret | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `PKR_VAR_proxmox_node` | Node name | `pve` |
| `PKR_VAR_ssh_password` | Temporary password | `SecurePassword123` |

---

**Sovereign, automated, and secure infrastructure.**
