# Nix Flakes

## Repository Structure

```
.
├── bin
│   ├── docker-nix.conf
│   └── make_iso.sh
├── CLAUDE.md
├── custom_iso.nix              <- NixOS image configuration
├── mbp2025                     <- MacOS flake with Nix-Darwin
│   ├── flake.lock
│   └── flake.nix
├── flake.lock
├── flake.nix
├── LICENSE
├── Makefile
├── mbp2023
│   └── flake.nix
├── nix.conf
├── README.md
└── servo
    ├── configuration.nix
    ├── flake.lock
    ├── flake.nix
    └── hardware-configuration.nix

```

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

1. Create a folder `~/.config/nix`.

1. Install [nix-darwin](https://github.com/nix-darwin/nix-darwin) running the command `sudo nix run nix-darwin -- switch --flake .#MBP2023` in the project root of this repository.

Two flakes divided into two folders:

```
.
├── mbp2025             <- MBP2025 flake file
│   ├── flake.lock
│   └── flake.nix
├── mbp2023             <- MBP2023 flake file
│   └── flake.nix
```

Update each computer with the corresponding command:

```bash
darwin-rebuild switch --flake ~/.config/nix/mbp2025#MBP2025
```
or
```bash
sudo darwin-rebuild switch --flake $(pwd)/mbp2023#MBP2023
```


## Building the ISO

### Instructions for Cross Generation: Build on aarch64-darwin deploy on x86_64

To build the NixOS ISO from this configuration, you will need to have Nix installed and flakes enabled. Due to the target architecture (`x86_64-linux`) being different from the host architecture (`aarch64-darwin`), you need to configure a remote builder or use emulation.

1. **Configure Nix for remote building:**

You can use the provided `nix.conf` file to configure your Nix environment. You can either copy its contents to your `~/.config/nix/nix.conf` or use it directly with the `nix` command.

2. **Build the ISO:**

Run the following command from the root of the repository:

```bash
nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.custom-iso.config.system.build.isolmage
```

This command tells Nix to use the local `nix.conf` file, which enables the use of a Linux builder.

The resulting ISO image will be in the `result/` directory.

### Instructions for Generation on an x86_64 VM

1. Install [Lima](https://github.com/lima-vm/lima)
2. Get the NixOS lima image from [github](https://github.com/kasuboski/nixos-lima) and run it.
3. Within the lima shell (using the `lima`) command, run the following command

```bash
nix run nixpkgs#nixos-generators -- --format iso --flake .#custom_iso -o result

```

## Installing NixOS from the ISO

Once you have built the ISO image, follow these steps to install NixOS on an x86_64 machine:

### 1. Write ISO to USB Drive

```bash
# Find your USB device (be careful to select the correct one!)
diskutil list  # on macOS
lsblk          # on Linux

# Write ISO to USB (replace /dev/diskX with your USB device)
sudo dd if=result of=/dev/rdiskX bs=4m status=progress  # macOS
sudo dd if=result of=/dev/sdX bs=4M status=progress     # Linux
```

### 2. Boot and Install

Boot from the USB drive on your x86_64 machine. The ISO already includes your servo configuration, so after installation, your system will have:
- Your defined users and packages
- Services (SSH, Syncthing, Tailscale, Docker)
- Network configuration

### 3. Installation Process

Since your ISO imports `servo/configuration.nix`, the installed system will automatically have your configuration. During installation:

```bash
# After booting from ISO
sudo nixos-install --flake github:yourusername/yourrepo#servidor
# OR if installing from local flake
sudo nixos-install --flake /mnt/path/to/flake#servidor
```

The key is that your `custom_iso.nix` already imports your servo configuration, so the ISO is pre-configured with your settings.

### 4. Disk Partitioning with Disko

The servo configuration includes a disko setup that defines disk partitioning. However, disko will NOT automatically partition disks during installation for safety reasons. You must manually apply the partitioning.

#### Disko Configuration Overview

The `servo/disko-config.nix` defines:
- **Boot partition (ESP)**: 512MB FAT32 at `/boot`
- **Root partition**: 64GB ext4 at `/`
- **Home partition**: 64GB ext4 at `/home`

#### Applying Disko Configuration

After booting from the ISO, you have two options:

**Option 1: Direct Disko Application**
```bash
# Download the disko configuration
curl -O https://raw.githubusercontent.com/yourusername/yourrepo/main/servo/disko-config.nix

# Apply disko (WARNING: This will destroy all data on the target disk!)
sudo nix run github:nix-community/disko -- --mode zap_create_mount ./disko-config.nix

# After disko completes, generate hardware configuration
sudo nixos-generate-config --root /mnt

# Install NixOS with your flake
sudo nixos-install --flake github:yourusername/yourrepo#servidor
```

**Option 2: Using the Installation Script**
```bash
# Download and run the installation script
curl -O https://raw.githubusercontent.com/yourusername/yourrepo/main/bin/install.sh
chmod +x install.sh
sudo ./install.sh
```

The installation script provides safety checks and guides you through the process.

**Important Notes:**
- Modify `/dev/sda` in `disko-config.nix` if your disk has a different name
- This process will **destroy all data** on the target disk
- Always backup important data before proceeding
- The remaining disk space after the defined partitions will be unallocated
