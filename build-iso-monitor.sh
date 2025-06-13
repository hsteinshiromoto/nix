#!/usr/bin/env bash
# Build and monitor NixOS ISO build

set -e

echo "Starting NixOS ISO build in Docker..."
echo "This may take 15-30 minutes..."

# Generate a unique container name
CONTAINER_NAME="nixos-iso-builder-$$"

# Run build without --rm so we can copy files after - use QEMU for x86_64
docker run \
  -v "$(pwd)":/workspace \
  -w /workspace \
  --name "$CONTAINER_NAME" \
  --platform linux/amd64 \
  --security-opt seccomp=unconfined \
  nixos/nix:latest sh -c "
    # Build for x86_64 using QEMU emulation
    nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage \
      -I nixos-config=./custom_iso.nix \
      --argstr system x86_64-linux \
      --option sandbox false \
      --option filter-syscalls false
" &

# Get the container process ID
BUILD_PID=$!

# Monitor the build
while kill -0 $BUILD_PID 2>/dev/null; do
    echo -n "."
    sleep 10
done

echo ""
echo "Build process finished!"

# Check if container exists and copy ISO
if docker ps -a | grep -q "$CONTAINER_NAME"; then
    echo "Checking for ISO in container..."
    
    # Get the ISO path from the result symlink
    ISO_PATH=$(docker exec "$CONTAINER_NAME" sh -c "if [ -L result ]; then readlink result; else echo ''; fi" 2>/dev/null || \
               docker start "$CONTAINER_NAME" >/dev/null 2>&1 && docker exec "$CONTAINER_NAME" sh -c "if [ -L result ]; then readlink result; else echo ''; fi" 2>/dev/null)
    
    if [ -n "$ISO_PATH" ]; then
        echo "Found ISO at: $ISO_PATH"
        
        # Copy the ISO from container to host
        ISO_NAME=$(basename "$ISO_PATH")
        echo "Copying $ISO_NAME to current directory..."
        
        # Check if ISO is in a subdirectory
        if docker exec "$CONTAINER_NAME" sh -c "test -f '$ISO_PATH'" 2>/dev/null; then
            docker cp "$CONTAINER_NAME:$ISO_PATH" "./$ISO_NAME" 2>/dev/null
        elif docker exec "$CONTAINER_NAME" sh -c "test -f '$ISO_PATH/iso/$ISO_NAME'" 2>/dev/null; then
            docker cp "$CONTAINER_NAME:$ISO_PATH/iso/$ISO_NAME" "./$ISO_NAME" 2>/dev/null
        else
            echo "Direct copy failed, trying alternative method..."
            # Alternative: copy via workspace
            docker exec "$CONTAINER_NAME" sh -c "find '$ISO_PATH' -name '*.iso' -type f -exec cp {} /workspace/ \;" 2>/dev/null && \
            echo "ISO copied successfully!"
        fi
        
        if [ -f "./$ISO_NAME" ]; then
            echo "✓ ISO successfully saved to: $(pwd)/$ISO_NAME"
            ls -lh "./$ISO_NAME"
        else
            echo "⚠ Warning: ISO copy may have failed"
        fi
    else
        echo "No ISO found in container result"
    fi
    
    # Clean up container
    echo "Cleaning up container..."
    docker rm "$CONTAINER_NAME" > /dev/null
else
    echo "Container not found - build may have failed"
fi