{ config, pkgs, lib, ... }:

{
  # SOPS configuration for home-manager
  sops = {
    # Use GPG for decryption
    gnupg.home = "${config.home.homeDirectory}/.gnupg";

    # Disable build-time validation to avoid sandbox permission issues on Darwin
    validateSopsFiles = false;

    # Fix PATH for Darwin launchd service (getconf is in /usr/bin)
    environment.PATH = lib.mkForce "/usr/bin:/bin:/usr/sbin:/sbin";
  };
}
