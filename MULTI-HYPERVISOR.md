# Multi-Hypervisor Build Guide

This project supports building Debian 13 templates on either:
- **Single hypervisor** (traditional mode)
- **Multiple hypervisors** (3 hypervisors in parallel)

## 🎯 Modes Available

### Mode 1: Single Hypervisor (Default)
Build on one Proxmox hypervisor at a time.

### Mode 2: Multi-Hypervisor (Parallel)
Build on 3 Proxmox hypervisors simultaneously:
- **Hypervisor 1**: 10.0.0.240 (server240)
- **Hypervisor 2**: 10.0.0.235 (server235)
- **Hypervisor 3**: 10.0.0.245 (server245)

## 📋 Prerequisites

### For All Hypervisors

Create API tokens on each Proxmox server:

```bash
# Run on each Proxmox server (10.0.0.240, 10.0.0.235, 10.0.0.245)
pveum user add packer@pve
pveum aclmod / -user packer@pve -role PVEVMAdmin
pveum user token add packer@pve packer-token --privsep=0
```

Save the token secrets displayed after each command.

### Configure .env File

Edit `.env` and add the tokens for each hypervisor:

```bash
# Edit the file
nano .env

# Update these lines with your actual tokens:
export PKR_VAR_proxmox_api_token_secret_hv2="your-token-for-235"
export PKR_VAR_proxmox_api_token_secret_hv3="your-token-for-245"
```

## 🚀 Usage

### Single Hypervisor Build

Build on the default hypervisor (10.0.0.240):

```bash
# Load environment
source .env

# Build
make build
```

### Multi-Hypervisor Build (All 3 in Parallel)

Build on all 3 hypervisors simultaneously:

```bash
# Load environment
source .env

# Build on all 3 hypervisors
make build-multi
```

**Result**: 3 templates created in parallel (~10-20 minutes)

### Build on Specific Hypervisor

Build on only one specific hypervisor:

```bash
# Hypervisor 1 (10.0.0.240)
make build-hv1

# Hypervisor 2 (10.0.0.235)
make build-hv2

# Hypervisor 3 (10.0.0.245)
make build-hv3
```

## 📊 Comparison

| Command | Hypervisors | Build Time | Use Case |
|---------|-------------|------------|----------|
| `make build` | 1 (default) | ~15 min | Standard deployment |
| `make build-multi` | 3 (parallel) | ~15 min | Multi-datacenter |
| `make build-hv1` | 1 (specific) | ~15 min | Test on specific HV |
| `make build-hv2` | 1 (specific) | ~15 min | Test on specific HV |
| `make build-hv3` | 1 (specific) | ~15 min | Test on specific HV |

## 🔧 Configuration Details

### HTTP Ports Used

Each hypervisor uses a different HTTP port to avoid conflicts:
- **HV1** (10.0.0.240): Port 8100
- **HV2** (10.0.0.235): Port 8101
- **HV3** (10.0.0.245): Port 8102

### Template Names

Templates are automatically named with the hypervisor suffix:
- `debian-13-template-YYYYMMDD-hv1` on 10.0.0.240
- `debian-13-template-YYYYMMDD-hv2` on 10.0.0.235
- `debian-13-template-YYYYMMDD-hv3` on 10.0.0.245

## ⚡ Advantages of Multi-Hypervisor Build

✅ **Time Efficient**: Build 3 templates in the time of 1
✅ **Consistency**: Same configuration across all hypervisors
✅ **Disaster Recovery**: Templates distributed across infrastructure
✅ **Load Balancing**: Ready for multi-datacenter deployments
✅ **Testing**: Easy to test on specific hypervisor

## 🛠️ Advanced Commands

### Validate Configuration

```bash
# Validate single hypervisor config
make validate

# No separate validation needed for multi - same command
```

### Debug Build

```bash
# Debug single hypervisor
make build-debug

# Debug multi-hypervisor
PACKER_LOG=1 make build-multi
```

### Force Build (Skip Validation)

```bash
# Force single
make build-force

# Force multi
source .env && packer build -force -var-file=variables-multi.pkr.hcl debian-13-multi.pkr.hcl
```

## 📝 Files Structure

```
.
├── debian-13.pkr.hcl          # Single hypervisor build config
├── debian-13-multi.pkr.hcl    # Multi-hypervisor build config
├── variables.pkr.hcl          # Common variables
├── variables-multi.pkr.hcl    # Multi-hypervisor specific variables
├── .env                       # Your credentials (DO NOT COMMIT)
├── .env.example               # Template for .env
└── Makefile                   # Build commands
```

## 🔐 Security Notes

- ✅ Never commit `.env` file
- ✅ Use different tokens for each hypervisor
- ✅ Limit API token privileges to minimum necessary
- ✅ Rotate tokens regularly
- ✅ In production, use valid TLS certificates

## ❓ Troubleshooting

### Build fails on one hypervisor

If multi-build fails on one hypervisor, you can:

1. Check which one failed in the output
2. Build on remaining hypervisors individually:
   ```bash
   make build-hv1  # If HV1 failed
   make build-hv2  # If HV2 failed
   make build-hv3  # If HV3 failed
   ```

### Port conflicts

If HTTP ports are already in use, edit `debian-13-multi.pkr.hcl` and change:
- `http_port_min` and `http_port_max` values

### Missing ISO on some hypervisors

Ensure the Debian ISO is present on all hypervisors:

```bash
# On each Proxmox server
cd /var/lib/vz/template/iso
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.2.0-amd64-netinst.iso
```

## 📚 Examples

### Standard Workflow

```bash
# 1. Configure environment
cp .env.example .env
nano .env  # Add your tokens

# 2. Load environment
source .env

# 3. Validate
make validate

# 4. Build on all 3 hypervisors
make build-multi
```

### Test on Single Hypervisor First

```bash
# Test on HV1 first
make build-hv1

# If successful, build on all
make build-multi
```

### Rolling Deployment

```bash
# Day 1: Build on HV1
make build-hv1

# Day 2: Build on HV2 (after testing HV1)
make build-hv2

# Day 3: Build on HV3 (after testing HV2)
make build-hv3
```

---

**🎉 Happy building on multiple hypervisors!**
