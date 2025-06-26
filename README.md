# Nix Flakes

## Repository Structure

```
.
├── bin
│   ├── docker-nix.conf
│   ├── install.sh
│   └── make_iso.sh
├── CLAUDE.md
├── custom_iso.nix
├── flake.lock
├── flake.nix
├── LICENSE
├── Makefile
├── mba2022
│   └── flake.nix
├── mbp2023
│   ├── flake.lock
│   └── flake.nix
├── mbp2025
│   ├── flake.lock
│   └── flake.nix
├── nix.conf
├── README.md
└── servo
    ├── configuration.nix
    ├── disko-config.nix
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
├── mba2022
│   └── flake.nix       <- MBA2022 flake file
├── mbp2025             <- MBP2025 flake file
│   ├── flake.lock
│   └── flake.nix
└── mbp2023             <- MBP2023 flake file
    └── flake.nix
```

Update each computer with the corresponding command:

```bash
darwin-rebuild switch --flake ~/.config/nix/mbp2025#MBP2025
```
or
```bash
sudo darwin-rebuild switch --flake $(pwd)/mbp2023#MBP2023
```


## Building the Custom ISO

### 1. Generate the image on an x86_64 VM

1. Install [Lima](https://github.com/lima-vm/lima)
2. Get the NixOS lima image from [github](https://github.com/kasuboski/nixos-lima) and run it.
3. Within the lima shell (using the `lima`) command, run the following command

```bash
nix run nixpkgs#nixos-generators -- --format iso --flake .#custom_iso -o result
```

### 2. Burn the ISO image to a USB Drive

1. Find your USB device (be careful to select the correct one!)

```bash
diskutil list  # on macOS
```


```bash
lsblk          # on Linux
```

2. Write ISO to USB (replace `/dev/diskX` with your USB device)

```bash
sudo dd if=result of=/dev/rdiskX bs=4m status=progress  # macOS
```

```bash
sudo dd if=result of=/dev/sdX bs=4M status=progress     # Linux
```


## Installing NixOS from the Customized ISO

### 1. Boot and Install

Boot from the USB drive on your x86_64 machine. The ISO already includes your servo configuration, so after installation, your system will have:
- Your defined users and packages
- Services (SSH, Syncthing, Tailscale, Docker)
- Network configuration

### 2. Disk Partitioning with Disko

The servo configuration includes a disko setup that defines disk partitioning. However, disko will NOT automatically partition disks during installation for safety reasons. You must manually apply the partitioning.

#### Disko Configuration Overview

The `servo/disko-config.nix` defines:
- **Boot partition (ESP)**: 512MB FAT32 at `/boot`
- **Root partition**: 64GB ext4 at `/`
- **Home partition**: 64GB ext4 at `/home`

#### Applying Disko Configuration

After booting from the ISO, you have two options:

**Option 1 (Recommended): Direct Disko Application**
```bash
# 1. Download the disko configuration
curl -O https://raw.githubusercontent.com/hsteinshiromoto/nix/main/servo/disko-config.nix

# 2. Apply disko (WARNING: This will destroy all data on the target disk!)
sudo nix run github:nix-community/disko -- --mode zap_create_mount ./disko-config.nix

# 3. After disko completes, generate hardware configuration
sudo nixos-generate-config --root /mnt
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

### 3. Installation Process

Since your ISO imports `servo/configuration.nix`, the installed system will automatically have your configuration. During installation:

**Option 1 (Recommended): Install by downloading the flake from github**
```bash
# After booting from ISO
sudo nixos-install --flake github:hsteinshiromoto/nix#servidor
```

** Option 2: From local flake**
```bash
sudo nixos-install --flake /mnt/path/to/flake#servidor
```

The key is that your `custom_iso.nix` already imports your servo configuration, so the ISO is pre-configured with your settings.
