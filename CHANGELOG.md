# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### ✨ Added
- **Static IP support for Terraform** - Cloud-Init network config disabled
- New script `05-configure-network.sh` for network configuration
- Complete Terraform documentation in `TERRAFORM-STATIC-IPS.md`
- Terraform examples for static IP deployment
- Network tools installation (ifupdown, iproute2, bridge-utils)
- Documentation embedded in template at `/root/NETWORK-CONFIG-INFO.txt`

### 🔧 Changed
- Updated `files/99-pve.cfg` - added `network: config: disabled`
- Updated `scripts/04-configure-cloud-init.sh` - removed network management
- Updated README.md with Terraform static IP section
- Updated `scripts/README.md` with new script documentation

### 📝 Documentation
- Added comprehensive guide `TERRAFORM-STATIC-IPS.md`
- Multiple Terraform examples (simple VM, multi-IP, clusters, modules)
- Troubleshooting section for network issues
- Best practices for static IP configuration

---

## [1.0.0] - 2025-11-20

### ✨ Added
- Complete Packer configuration for Debian 13 on Proxmox VE
- UEFI support with GRUB
- Automated installation via preseed
- Modular provisioning scripts in \`scripts/\`
  - System update
  - Essential package installation
  - Secure SSH configuration
  - Cloud-Init configuration
  - Automatic cleanup
- Makefile for task automation
- \`variables.auto.pkrvars.hcl\` file for default values
- \`packer.pkr.hcl\` file for centralized configuration
- Complete documentation (README.md)
- Scripts documentation (scripts/README.md)
- Secure secret management via \`.env\`
- QEMU Guest Agent support
- Cloud-Init configuration for Proxmox
- MIT License
- EditorConfig for code consistency

### 🔒 Security
- Sensitive variables marked as \`sensitive\`
- Secrets via environment variables only
- Complete \`.gitignore\` to prevent leaks
- Secure SSH configuration by default
- Public key authentication enabled
- Root password disabled

### 📝 Documentation
- Complete installation guide
- Customization instructions
- Troubleshooting section
- Scripts documentation
- Usage examples

### 🛠️ Configuration
- CPU: 2 cores by default
- RAM: 2048 MB by default
- Disk: 20G by default
- Network: vmbr0 by default
- Template ID: 9012 by default

---

## Release Notes

### Version 1.0.0 - Main Features

This first stable version provides:
- ✅ Functional Debian 13 template for Proxmox VE
- ✅ Fully automated installation
- ✅ Modular and maintainable scripts
- ✅ Complete documentation
- ✅ Secure credential management
- ✅ Optimized configuration for Proxmox
- ✅ Complete Cloud-Init support

### Planned Future Versions

#### v1.1.0 (Coming)
- [ ] Multi-architecture support (arm64)
- [ ] Additional configuration templates
- [ ] Automated tests with GitHub Actions
- [ ] Optional Ansible post-provisioning support

#### v1.2.0 (Coming)
- [ ] Template variants (minimal, server, desktop)
- [ ] Performance optimizations
- [ ] IPv6 support
- [ ] Automatic firewall configuration

---

## Entry Format

Changes are categorized as follows:
- **Added**: New features
- **Changed**: Changes to existing features
- **Deprecated**: Features soon to be removed
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Vulnerability fixes

---

**Legend**:
- ✨ New feature
- 🔒 Security improvement
- 🐛 Bug fix
- 📝 Documentation
- 🛠️ Configuration
- ⚡ Performance
- 🔧 Maintenance

[Unreleased]: https://github.com/your-repo/packer-proxmox-debian-13/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/your-repo/packer-proxmox-debian-13/releases/tag/v1.0.0
