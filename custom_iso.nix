# custom-iso.nix
{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    servo/configuration.nix
  ];

	# Explicitly override any wireless settings from other modules
  networking.wireless.enable = false;

  # Ensure NetworkManager is enabled (though this is already in your configuration.nix)
  networking.networkmanager.enable = true;
}
