# SOPS secrets management configuration
# See: https://github.com/Mic92/sops-nix

{ config, ... }:

{
  sops = {
    defaultSopsFile = /home/hsteinshiromoto/.config/sops/secrets/ssh.yaml;
    defaultSopsFormat = "yaml";
    # Use GPG for decryption instead of age
    gnupg = {
      home = "/home/hsteinshiromoto/.gnupg";
      sshKeyPaths = [];  # Don't derive GPG keys from SSH keys
    };
    secrets = {
      "authorized_keys" = {  # Direct key, not nested under ssh/
        mode = "0644";  # Needs to be readable by sshd
        # Don't set owner - let it be root owned
      };
      "samba_password" = {
        sopsFile = /home/hsteinshiromoto/.config/sops/secrets/common/samba.yaml;
        key = "samba/password";
        mode = "0600";
        owner = "root";
      };
    };
  };
}
