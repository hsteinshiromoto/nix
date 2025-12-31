# Server Instructions.

## Installing NixOS

1. Download the iso.
2. Burn the iso into a usb stick.
3. Boot the usb into the server.
4. When boot, set connection with `nmtui`.

## Important Notes

1. Never makes NixOS start up to depend on a external disk.
2. The installation below may fail due to dependencyon sops secrets.

## Partition the Disk

### Method 1: Using disko directly (Recommended)

1. Clone the repository (if not already available):
```bash
git clone https://github.com/hsteinshiromoto/nix ~/.config/nix
cd ~/.config/nix
```

2. Use disko to create the partitions:
```bash
sudo nix run github:nix-community/disko -- --mode zap_create_mount /home/nixos/.config/nix/servo/disko-config.nix
```
his command will:
- Zap (wipe) the target disk
- Create the partitions according to your disko config
- Mount them at `/mnt` and `/mnt/boot`

### Method 2: Using Parted

1. Set the partition UEFI (GPT)
    a. Create a GPT partition table.
    ```bash
    # parted /dev/sda -- mklabel gpt
    ```
    b. Add the root partition. This will fill the disk except for the end part, where the swap will live, and the space left in front (512MiB) minus 8GB which will be used by the boot partition.
    ```bash
    # parted /dev/sda -- mkpart root ext4 512MB -8GB
    ```
    c. Next, add a swap partition. The size required will vary according to needs, here a 8GB one is created.
    ```bash
    # parted /dev/sda -- mkpart swap linux-swap -8GB 100%
    ```
    d. Finally, the boot partition. NixOS by default uses the ESP (EFI system partition) as its /boot partition. It uses the initially reserved 512MiB at the start of the disk.
    ```bash
    # parted /dev/sda -- mkpart ESP fat32 1MB 512MB
    # parted /dev/sda -- set 3 esp on
    ```
2. Format the disk:
    a. For initialising Ext4 partitions: `mkfs.ext4`. It is recommended that you assign a unique symbolic label to the file system using the option `-L label`, since this makes the file system configuration independent from device changes. For example:
    ```bash
    # mkfs.ext4 -L nixos /dev/sda1
    ```
    b. For creating swap partitions: `mkswap`. Again it’s recommended to assign a label to the swap partition: `-L label`. For example:
    ```bash
    # mkswap -L swap /dev/sda2
    ```
    c. **UEFI systems**: For creating boot partitions: `mkfs.fat`. Again it’s recommended to assign a label to the boot partition: `-n label`. For example:
    ```bash
    # mkfs.fat -F 32 -n boot /dev/sda3
    ```
3. Mount the target file system on which NixOS should be installed on `/mnt`, e.g.
```bash
# mount /dev/disk/by-label/nixos /mnt
```
4. **UEFI systems**: Mount the boot file system on `/mnt/boot`, e.g.
```bash
# mkdir -p /mnt/boot
# mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
```
5. If your machine has a limited amount of memory, you may want to activate swap devices now (`swapon` device). The installer (or rather, the build actions that it may spawn) may need quite a bit of RAM, depending on your configuration.
```bash
# swapon /dev/sda2
```
6. You now need to create a file `/mnt/etc/nixos/configuration.nix` that specifies the intended configuration of the system
```bash
# nixos-generate-config --flake --root /mnt
```
7. You should then edit /mnt/etc/nixos/configuration.nix to suit your needs:
```bash
# nano /mnt/etc/nixos/configuration.nix
```

## Install NixOS

### Method 1. From Flake (Recommended)

Install NixOS using your flake:
```bash
sudo nixos-install --flake '~/.config/nix#servidor
```

### Method 2. From Scratch

1. If using the generated configuration to start. You have to enable network manager **before** installing NixOS. In the `configuration.nix`, make that the following line is left uncommented:

```nix
networking.networkmanager.enable = true;
```

2. Do the installation:
```bash
sudo nixos-install
```

3. Clone the this repository as follows:
```bash
$ mkdir -p ~/.config
$ git clone https://github.com/hsteinshiromoto/nix ~/.config/nix
```

4. Do the installation:
```bash
sudo nixos-install --flake '~/.config/nix#servidor'
```

## Finalizing

1. As the last step, nixos-install will ask you to set the password for the root user, e.g.
```bash
setting root password...
New password: ***
Retype new password: ***
```

2. If you have a user account declared in your configuration.nix and plan to log in using this user, set a password before rebooting, e.g. for the `hsteinshiromoto` user:
```bash
sudo nixos-enter --root /mnt -c 'passwd hsteinshiromoto'
```

3. Reboot with `# reboot`.

4. Applicable if installed from flake: clone the repository again and create a symbolic link for the `servo/configuration.nix` file:
```bash
sudo ln -s /home/hsteinshiromoto/.config/nix/servo/configuration.nix /etc/nixos/
```

## Upgrade with the command

```bash
# nixos-rebuild switch --flake .#servidor --upgrade
```

## Create Custom ISO Image

### 1. Generate iso image

1. Use the command using Makefile as `make iso` or the following cli
```bash
nix run nixpkgs#nixos-generators -- --format iso --flake .#custom_iso -o result
```

2. Copy the iso image to the current folder

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

