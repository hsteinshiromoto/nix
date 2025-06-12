# custom-iso.nix
{ config, pkgs, pkgsUnstable, lib, modulesPath, ... }:
{
  imports = [
		# Use modulesPath to access installer modules
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    # Or for a graphical installer:
    # (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")

    # Include channel information
    (modulesPath + "/installer/cd-dvd/channel.nix")
  ];

	# Explicitly override any wireless settings from other modules
  networking.wireless.enable = false;

  # Ensure NetworkManager is enabled
  networking.networkmanager.enable = true;

	# Enable flakes in the ISO
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Copy your flake to the ISO
  environment.etc = {
    "install-flake/flake.nix".source = ./flake.nix;
    "install-flake/flake.lock".source = ./flake.lock;
    "install-flake/servo/configuration.nix".source = ./servo/configuration.nix;
    "install-flake/servo/flake.nix".source = ./servo/flake.nix;
  };

  # Add automated installation script
  environment.systemPackages = with pkgs; [
    (writeScriptBin "nixos-install-auto" ''
      #!${pkgs.runtimeShell}
      set -e
      
      echo "=== Automated NixOS Installation ==="
      echo "This will ERASE /dev/sda and install NixOS with your configuration!"
      echo "Press Ctrl-C within 10 seconds to cancel..."
      sleep 10
      
      # Copy flake to a working directory
      cp -r /etc/install-flake /tmp/
      cd /tmp/install-flake
      
      # Run disko to partition and format disks
      echo "Partitioning disks with disko..."
      nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake /tmp/install-flake#servidor
      
      # Install NixOS using the flake
      echo "Installing NixOS..."
      nixos-install --flake /tmp/install-flake#servidor --no-root-password
      
      echo "Installation complete! You can now reboot."
    '')
  ];

  # Add instructions to the MOTD
  services.getty.helpLine = ''
    
    === Automated NixOS Installer ===
    
    WARNING: This will ERASE /dev/sda completely!
    
    To install NixOS automatically with pre-configured partitions:
    Run: nixos-install-auto
    
    To install manually:
    1. Partition your disks manually
    2. Run: nixos-generate-config --root /mnt
    3. Edit /mnt/etc/nixos/configuration.nix
    4. Run: nixos-install
  '';
}
