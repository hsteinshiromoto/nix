# custom-iso.nix
{ config, pkgs, pkgsUnstable, lib, modulesPath, ... }:
{
  imports = [
    # Disable manual generation to avoid the optionsDocBook error
    ({ config, ... }: {
      documentation.enable = false;
      documentation.nixos.enable = false;
    })
    # Use modulesPath to access installer modules
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    # Or for a graphical installer:
    # (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")

    # Include channel information
    (modulesPath + "/installer/cd-dvd/channel.nix")
    ./configuration.nix
  ];

	# Explicitly override any wireless settings from other modules
  networking.wireless.enable = false;

  # Ensure NetworkManager is enabled (though this is already in your configuration.nix)
  networking.networkmanager.enable = true;

	# Enable flakes in the ISO
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
