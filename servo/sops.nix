# SOPS secrets management configuration
# See: https://github.com/Mic92/sops-nix

{ config, ... }:

{
  sops = {
    defaultSopsFile = /home/hsteinshiromoto/.config/sops/secrets/ssh.yaml;
    defaultSopsFormat = "yaml";
    # Use age key derived from SSH host key for decryption
    age = {
      # Derive age key from SSH host key
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      # No separate age key file needed
      keyFile = null;
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
