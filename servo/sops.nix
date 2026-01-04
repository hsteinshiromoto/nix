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

  # Sync SOPS SSH authorized_keys to user directories
  systemd.services.sops-ssh-keys-sync = {
    description = "Sync SOPS SSH authorized_keys to users";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
    # Restart on every nixos-rebuild to pick up new keys
    restartIfChanged = true;
    restartTriggers = [ config.sops.secrets."authorized_keys".path ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };

    script = ''
      # Wait for SOPS secret to be available
      SECRET_PATH="${config.sops.secrets."authorized_keys".path}"

      if [ ! -f "$SECRET_PATH" ]; then
        echo "ERROR: SOPS secret not found at $SECRET_PATH"
        exit 1
      fi

      echo "Syncing SSH authorized_keys from SOPS..."

      # Sync for hsteinshiromoto user
      HUSER_SSH_DIR="/home/hsteinshiromoto/.ssh"
      mkdir -p "$HUSER_SSH_DIR"
      cp "$SECRET_PATH" "$HUSER_SSH_DIR/authorized_keys"
      chown hsteinshiromoto:users "$HUSER_SSH_DIR/authorized_keys"
      chmod 600 "$HUSER_SSH_DIR/authorized_keys"
      chown hsteinshiromoto:users "$HUSER_SSH_DIR"
      chmod 700 "$HUSER_SSH_DIR"

      # Sync for git user
      GIT_SSH_DIR="/var/lib/git-server/.ssh"
      mkdir -p "$GIT_SSH_DIR"
      cp "$SECRET_PATH" "$GIT_SSH_DIR/authorized_keys"
      chown git:git "$GIT_SSH_DIR/authorized_keys"
      chmod 600 "$GIT_SSH_DIR/authorized_keys"
      chown git:git "$GIT_SSH_DIR"
      chmod 700 "$GIT_SSH_DIR"

      echo "SSH authorized_keys synced successfully"
    '';
  };
}
