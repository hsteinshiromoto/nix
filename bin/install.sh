#!/bin/bash
# install.sh - Installation script for servo NixOS system
# This script uses disko to apply the partitioning configuration

set -e

echo "=== Servo NixOS Installation Script ==="
echo "This script will install NixOS using the disko partitioning configuration."
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Check if we're in the right directory
if [[ ! -f "configuration.nix" ]]; then
    echo "Error: configuration.nix not found. Please run this script from the servo directory."
    exit 1
fi

echo "Current disk layout:"
lsblk

echo ""
echo "WARNING: This will destroy all data on the target disk!"
echo "Make sure you have backed up any important data."
echo ""
read -p "Enter the target disk device (e.g., /dev/sda): " TARGET_DISK

if [[ ! -b "$TARGET_DISK" ]]; then
    echo "Error: $TARGET_DISK is not a valid block device"
    exit 1
fi

echo ""
echo "Target disk: $TARGET_DISK"
read -p "Are you sure you want to proceed? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "Applying disko configuration..."

# Apply disko configuration
nix run github:nix-community/disko -- --mode zap_create_mount ./disko-config.nix

echo ""
echo "Disko configuration applied successfully!"
echo ""
echo "Next steps:"
echo "1. Mount the filesystems:"
echo "   mount /dev/disk/by-label/nixos /mnt"
echo "   mount /dev/disk/by-label/home /mnt/home"
echo "   mount /dev/disk/by-label/ESP /mnt/boot"
echo ""
echo "2. Generate NixOS configuration:"
echo "   nixos-generate-config --root /mnt"
echo ""
echo "3. Copy your configuration:"
echo "   cp configuration.nix /mnt/etc/nixos/"
echo "   cp disko-config.nix /mnt/etc/nixos/"
echo ""
echo "4. Install NixOS:"
echo "   nixos-install --root /mnt"
echo ""
echo "5. Reboot:"
echo "   reboot" 