{ config, pkgs, ... }:

{
  # SOPS configuration for home-manager
  sops = {
    # Use GPG for decryption
    gnupg.home = "${config.home.homeDirectory}/.gnupg";

    # Disable build-time validation to avoid sandbox permission issues on Darwin
    validateSopsFiles = false;
  };
}
