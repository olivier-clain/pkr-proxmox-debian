#!/bin/bash
# Script 01: System Update
# Description: Updates all system packages

set -euo pipefail

echo "==> Updating Debian system..."

# Update package list
echo "==> Updating package list..."
apt-get update

# Update installed packages
echo "==> Upgrading packages..."
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Full upgrade if necessary
echo "==> Full system upgrade..."
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

echo "==> System updated successfully"
