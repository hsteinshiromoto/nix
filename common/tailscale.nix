{ config, pkgs, lib, ... }:

lib.mkMerge [
  # --- Common Tailscale configuration (all hosts) ---
  {
    # Enable Tailscale service
    services.tailscale = {
      enable = true;
    };
  }

  # --- Host-specific: servidor ---
  (lib.mkIf (config.networking.hostName == "servidor") {
    # Tailscale service configuration with auth key
    services.tailscale = {
      authKeyFile = config.sops.secrets."tailscale_auth_key".path;
    };

    # Auto-authentication service
    # This ensures Tailscale automatically re-authenticates after reboots/rebuilds
    # using the SOPS-managed auth key
    systemd.services.tailscale-auto-auth = {
      description = "Tailscale automatic authentication";
      after = [ "tailscaled.service" "sops-nix.service" ];
      wants = [ "sops-nix.service" ];
      requires = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      path = [ pkgs.tailscale pkgs.jq pkgs.gnugrep ];

      script = ''
        # Wait for tailscaled to be ready
        sleep 2

        # Check if auth key file exists
        if [ ! -f "${config.sops.secrets."tailscale_auth_key".path}" ]; then
          echo "ERROR: Tailscale auth key secret not available at ${config.sops.secrets."tailscale_auth_key".path}"
          exit 1
        fi

        # Check current authentication state
        BACKEND_STATE=$(${pkgs.tailscale}/bin/tailscale status --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.BackendState' || echo "Unknown")

        if [ "$BACKEND_STATE" != "Running" ]; then
          echo "Tailscale not authenticated (state: $BACKEND_STATE). Authenticating with auth key..."

          # Read auth key from SOPS secret
          AUTH_KEY=$(cat "${config.sops.secrets."tailscale_auth_key".path}")

          if [ -z "$AUTH_KEY" ]; then
            echo "ERROR: Auth key is empty"
            exit 1
          fi

          # Authenticate with Tailscale
          ${pkgs.tailscale}/bin/tailscale up --authkey="$AUTH_KEY" --accept-routes

          if [ $? -eq 0 ]; then
            echo "Tailscale authentication successful"
          else
            echo "ERROR: Tailscale authentication failed"
            exit 1
          fi
        else
          echo "Tailscale already authenticated and running"
        fi
      '';
    };
  })
]
