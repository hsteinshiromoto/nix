#!/usr/bin/env bash
set -e

# --- Helper Functions ---

# Check for required commands
check_command() {
  if ! command -v "$1" &>/dev/null; then
    echo "Error: command '$1' not found. Please install it."
    exit 1
  fi
}

# Cleanup function on exit
cleanup() {
  if [ -n "$CID" ]; then
    echo "Stopping container..."
    docker stop "$CID" >/dev/null
  fi
  # No cleanup needed for Lima as the VM persists
}

# --- Builder Implementations ---

# Build using Docker
build_with_docker() {
  check_command docker
  echo "## Starting Docker container..."
  CID=$(docker run --rm -d \
    --platform=linux/amd64 \
    --privileged \
    -v "$(pwd)":/workspace \
    -v nix-store:/nix \
    -w /workspace \
    nixos/nix:latest \
    sleep infinity)
  
  trap cleanup EXIT

  echo "## Starting Nix daemon in container..."
  docker exec "$CID" sh -c "mkdir -p /etc/nix && cp /workspace/nix.conf /etc/nix/nix.conf && nix-daemon &"
  
  echo "Waiting for daemon to start..."
  until docker exec "$CID" test -e /nix/var/nix/daemon-socket/socket; do
    echo -n "."
    sleep 1
  done
  echo " Daemon ready."

  echo "## Building ISO image with Docker..."
  docker exec "$CID" nix build .#nixosConfigurations.custom-iso.config.system.build.isoImage --impure --no-sandbox
  
  echo "## Copying ISO from container..."
  docker exec "$CID" cp -L /workspace/result /workspace/nixos-x86_64.iso
}

# Build using Lima
build_with_lima() {
  check_command limactl
  local vm_name="default"

  if ! limactl list "$vm_name" --json | grep -q '"status":"Running"'; then
    echo "Lima VM '$vm_name' is not running."
    echo "You can create and start one with:"
    echo "limactl start --arch=x86_64 --name=$vm_name"
    exit 1
  fi

  echo "## Installing Nix in Lima VM (if not present)..."
  limactl shell "$vm_name" sh -c '
    if ! command -v nix &>/dev/null; then
      echo "Nix not found. Installing..."
      curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
    fi
    # Source nix for the current session
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    
    # Ensure nix.conf is in place
    mkdir -p "$HOME/.config/nix"
    cp "$(pwd)/nix.conf" "$HOME/.config/nix/nix.conf"

    echo "## Building ISO image with Lima..."
    ISO_PATH=$(nix path-info .#nixosConfigurations.custom-iso.config.system.build.isoImage --impure --extra-experimental-features "nix-command flakes")
  '
  
  echo "## Copying ISO from Lima VM..."
  limactl shell "$vm_name" cp -L "$ISO_PATH" "$(pwd)/nixos-x86_64.iso"
}

# --- Main Logic ---

echo "## ISO Build Script for macOS ##"

# We can only run this script on macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "This script is intended to run on macOS only."
    exit 1
fi


if command -v limactl &>/dev/null; then
  echo "Lima detected. Using Lima for the build."
  build_with_lima
else
  echo "Lima not found. Falling back to Docker."
  build_with_docker
fi

# The file is now available on the host. Clean up the symlink.
rm -f result

echo "✅  ISO ready: nixos-x86_64.iso"
