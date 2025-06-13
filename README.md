# Nix Flakes

## Repository Structure

```
.
├── CLAUDE.md
├── custom_iso.nix              <- NixOS ISO configuration with embedded flake
├── build-iso.sh                <- Quick ISO build script for x86_64
├── build-iso-monitor.sh        <- ISO build with progress monitoring
├── darwin                      <- MacOS flake with Nix-Darwin
│   ├── flake.lock
│   └── flake.nix
├── flake.lock
├── flake.nix                   <- Main flake file
├── LICENSE
├── README.md
└── servo                       <- Server NixOS configuration
    ├── configuration.nix
    ├── flake.lock
    └── flake.nix

```

## Automated NixOS Installation

### Building the Custom ISO

#### Building on macOS (ARM64)

For macOS users, we provide Docker-based build scripts that handle x86_64 ISO generation using QEMU emulation:

1. **Quick build:**
   ```bash
   ./build-iso.sh
   ```

2. **Build with progress monitoring (recommended):**
   ```bash
   ./build-iso-monitor.sh
   ```
   This script shows build progress and automatically copies the ISO to your current directory.

The ISO will be created as `nixos-minimal-25.05pre-git-x86_64-linux.iso` (approximately 1.6GB).

**Note:** Building x86_64 ISOs on ARM64 Macs uses QEMU emulation and may take 5-10 minutes.

#### Building on Linux

If you're on a Linux system, you can build directly:

```bash
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./custom_iso.nix
```

The ISO will be created in `./result/iso/`.

### Automated Installation Process

This custom ISO includes an automated installer that will:
- Automatically partition your disk according to the disko configuration in `servo/configuration.nix`
- Install NixOS with all settings from the flake
- Configure the system exactly as defined in your configuration

**⚠️ WARNING: This process will COMPLETELY ERASE `/dev/sda`! Make sure to backup any important data.**

#### Installation Steps:

1. **Burn the ISO to a USB drive:**
   ```bash
   # On macOS
   sudo dd if=nixos-minimal-25.05pre-git-x86_64-linux.iso of=/dev/rdiskN bs=1m
   
   # On Linux
   sudo dd if=nixos-minimal-25.05pre-git-x86_64-linux.iso of=/dev/sdX bs=4M status=progress
   ```

2. **Boot from the USB drive**

3. **Run the automated installer:**
   ```bash
   nixos-install-auto
   ```

   The installer will:
   - Show a 10-second warning before proceeding
   - Partition `/dev/sda` with:
     - 512MB EFI boot partition
     - 20% of disk for root partition
     - ~75% of disk for home partition
   - Format and mount all partitions
   - Install NixOS with your complete configuration
   - Set up the system ready for first boot

4. **Reboot when installation completes:**
   ```bash
   reboot
   ```

### Manual Installation (Alternative)

If you prefer to partition manually or use a different disk:

1. Partition and format your disks manually
2. Mount them (root at `/mnt`, boot at `/mnt/boot`, etc.)
3. Generate hardware configuration: `nixos-generate-config --root /mnt`
4. Install: `nixos-install --flake /etc/install-flake#servidor`

## Servidor

1. Create the symbolic links of the files in `servo/` folder to `/etc/nixos`.

2. Run the command from the folder `/etc/nixos/`
```bash
sudo nix flake update --flake . --impure
```

3. Rebuild with from the project root folder
```bash
sudo nixos-rebuild test --flake .#servidor --impure
```

To switch to a new build, replace the `test` with `switch`.

## Darwin

`darwin/flake.nix`

Uptate Darwin with

```bash
darwin-rebuild switch --flake ~/.config/nix/darwin#MBP2025
```
