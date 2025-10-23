{ config, pkgs, ... }:

{
  # SOPS configuration for MBP2025
  sops = {
    # Use GPG for decryption
    gnupg.home = "${config.home.homeDirectory}/.gnupg";

    # Disable build-time validation to avoid sandbox permission issues on Darwin
    validateSopsFiles = false;

    # No defaultSopsFile - each secret will specify its own sopsFile
    # This allows loading from multiple files in the secrets folder:
    # - ~/.config/sops/secrets/gitconfig.yaml
    # - ~/.config/sops/secrets/gitlab.yaml (if needed)
    # - etc.
  };
}
