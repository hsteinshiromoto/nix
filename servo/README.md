# Server Instructions.

## Installing NixOS

1. Download the iso.
2. Burn the iso into a usb stick.
3. Boot the usb into the server.
4. When boot, set connection with `nmtui`.

## Partition the Disk

### Method 1: Using disko directly (Recommended)

1. Clone the repository (if not already avaible):
```bash
git clone https://github.com/hsteinshiromoto/nix ~/.config/nix
cd ~/.config/nix
```

2. Use disko to create the partitions:
```bash
nix run github:nix-community/disko -- --mode zap_create_mount ~/.config/nix/servo/disko-config.nix
```
his command will:
- Zap (wipe) the target disk
- Create the partitions according to your disko config
- Mount them at `/mnt` and `/mnt/boot`

3. Install NixOS using your flake:
```bash
nixos-install --flake '~/.config/nix#servidor
```

### Using Parted
5. Set the partition UEFI (GPT)
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
6. Format the disk:
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
7. Mount the target file system on which NixOS should be installed on `/mnt`, e.g.
```bash
# mount /dev/disk/by-label/nixos /mnt
```
8. **UEFI systems**: Mount the boot file system on `/mnt/boot`, e.g.
```bash
# mkdir -p /mnt/boot
# mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
```
9. If your machine has a limited amount of memory, you may want to activate swap devices now (`swapon` device). The installer (or rather, the build actions that it may spawn) may need quite a bit of RAM, depending on your configuration.
```bash
# swapon /dev/sda2
```
10. You now need to create a file `/mnt/etc/nixos/configuration.nix` that specifies the intended configuration of the system
```bash
# nixos-generate-config --flake --root /mnt
```
11. You should then edit /mnt/etc/nixos/configuration.nix to suit your needs:
```bash
# nano /mnt/etc/nixos/configuration.nix
```

### From Scratch

11.a. If using the generated configuration to start. You have to enable network manager **before** installing NixOS. In the `configuration.nix`, make that the following line is left uncommented:

```nix
networking.networkmanager.enable = true;
```

12. Do the installation:
```bash
# nixos-install
```

### From Flake

11.a. Clone the this repository as follows:
```bash
$ mkdir -p ~/.config
$ git clone https://github.com/hsteinshiromoto/nix ~/.config/nix
```

12. Do the installation:
```bash
# nixos-install --flake '~/.config/nix#servidor'
```

13. As the last step, nixos-install will ask you to set the password for the root user, e.g.
```bash
setting root password...
New password: ***
Retype new password: ***
```
If you have a user account declared in your configuration.nix and plan to log in using this user, set a password before rebooting, e.g. for the `hsteinshiromoto` user:
```bash
nixos-enter --root /mnt -c 'passwd hsteinshiromoto'
```

14. Reboot with `# reboot`.

## Upgrade with the command

```bash
# nixos-rebuild switch --flake .#servidor --upgrade
```