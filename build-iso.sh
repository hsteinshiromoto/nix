#!/usr/bin/env bash
# Build NixOS ISO for x86_64 architecture on macOS using Docker

set -e

echo "Building NixOS ISO for x86_64 using Docker..."

# Option 1: Using Docker with QEMU emulation for x86_64 architecture
docker run --rm \
  -v "$(pwd)":/workspace \
  -w /workspace \
  --platform linux/amd64 \
  nixos/nix:latest sh -c "
  # Build the ISO for x86_64 using QEMU
  nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage \
    -I nixos-config=./custom_iso.nix \
    --argstr system x86_64-linux \
    --option sandbox false
  
  # Copy the ISO to the workspace
  if [ -L result ]; then
    ISO_PATH=\$(readlink result)
    if [ -f \"\$ISO_PATH\" ]; then
      cp \"\$ISO_PATH\" /workspace/
      echo \"ISO copied to: \$(basename \"\$ISO_PATH\")\"
    elif [ -f \"\$ISO_PATH/iso/\"*.iso ]; then
      cp \"\$ISO_PATH/iso/\"*.iso /workspace/
      echo \"ISO copied from iso subdirectory\"
    fi
  fi
"

# Option 2: Using cross-compilation (experimental)
# Uncomment to try cross-compilation instead
# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage \
#   -I nixos-config=./custom_iso.nix \
#   --arg crossSystem '{ system = "x86_64-linux"; }'