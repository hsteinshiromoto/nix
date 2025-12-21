{ config, pkgs, lib, ... }:

let
  tmUser = "hsteinshiromoto";
  tmPath = "/home/timemachine";

  tmCheckScript = pkgs.writeScriptBin "tm-check" ''
    #!${pkgs.bash}/bin/bash
    # Check Time Machine service status and configuration

    echo "Time Machine Status"
    echo "===================="
    echo ""
    echo "Samba SMB service: $(systemctl is-active samba-smbd)"
    echo "Samba NMB service: $(systemctl is-active samba-nmbd)"
    echo ""
    echo "Mount point: ${tmPath}"
    echo "Space available:"
    ${pkgs.coreutils}/bin/df -h ${tmPath}
    echo ""
    echo "Samba users:"
    ${pkgs.samba}/bin/pdbedit -L 2>/dev/null || echo "No Samba users configured"
    echo ""
    echo "Firewall status:"
    sudo ${pkgs.iptables}/bin/iptables -L -n | ${pkgs.gnugrep}/bin/grep -E "(445|139)" || echo "Samba ports not found in firewall rules"
    echo ""
    echo "Recent Samba logs:"
    ${pkgs.systemd}/bin/journalctl -u samba-smbd -n 20 --no-pager
  '';

  tmUsageScript = pkgs.writeScriptBin "tm-usage" ''
    #!${pkgs.bash}/bin/bash
    # Show Time Machine disk usage

    echo "Time Machine Usage"
    echo "=================="
    echo ""
    if [ -d "${tmPath}" ]; then
      echo "Total usage:"
      ${pkgs.coreutils}/bin/du -sh ${tmPath}
      echo ""
      echo "Breakdown by directory:"
      ${pkgs.coreutils}/bin/du -sh ${tmPath}/* 2>/dev/null || echo "No backups yet"
    else
      echo "Error: Time Machine directory ${tmPath} does not exist"
    fi
  '';

in {
  # Create Time Machine directory
  systemd.tmpfiles.rules = [
    "d ${tmPath} 0750 ${tmUser} users -"
  ];

  # Samba configuration for Time Machine
  services.samba = {
    enable = true;
    openFirewall = true;  # Opens TCP ports 139, 445 and UDP ports 137, 138

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "servidor Time Machine";
        "netbios name" = "servidor";
        "security" = "user";

        # Security: restrict to local network and Tailscale
        # Tailscale uses 100.x.x.x range (CGNAT space)
        "hosts allow" = "192.168.1. 192.168.0. 100. 127.0.0.1";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";

        # Performance optimizations
        "min receivefile size" = "16384";
        "use sendfile" = "true";
        "aio read size" = "16384";
        "aio write size" = "16384";

        # Connection stability for Time Machine
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_KEEPALIVE";
        "deadtime" = "30";  # Minutes before idle connection is closed
        "keepalive" = "60";  # Send keepalive every 60 seconds
        "max connections" = "10";

        # macOS compatibility - VFS modules
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
      };

      "TimeMachine" = {
        "path" = tmPath;
        "valid users" = tmUser;
        "public" = "no";
        "writeable" = "yes";
        "force user" = tmUser;
        "force group" = "users";
        "create mask" = "0600";
        "directory mask" = "0700";

        # Time Machine specific settings
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = "500G";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };

  # Systemd service to sync Samba password from SOPS
  systemd.services.sops-samba-password-sync = {
    description = "Sync SOPS Samba password for Time Machine";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" "samba-smbd.service" ];
    wants = [ "sops-nix.service" "samba-smbd.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      PASSWORD_FILE="${config.sops.secrets.samba_password.path}"

      if [ -f "$PASSWORD_FILE" ]; then
        echo "Setting Samba password for ${tmUser} from SOPS secret..."

        # Read password and remove any trailing newlines
        PASSWORD=$(${pkgs.coreutils}/bin/cat "$PASSWORD_FILE" | ${pkgs.coreutils}/bin/tr -d '\n')

        # Set Samba password non-interactively using printf
        ${pkgs.coreutils}/bin/printf "%s\n%s\n" "$PASSWORD" "$PASSWORD" | \
          ${pkgs.samba}/bin/smbpasswd -s -a ${tmUser}

        if [ $? -eq 0 ]; then
          echo "Successfully added Samba user ${tmUser}"
        else
          echo "ERROR: Failed to add Samba user ${tmUser}"
          exit 1
        fi
      else
        echo "WARNING: SOPS secret for Samba password not found at $PASSWORD_FILE"
        echo "Please create the secret file or run: sudo smbpasswd -a ${tmUser}"
        exit 1
      fi
    '';
  };

  # Add helper scripts to system packages
  environment.systemPackages = [
    tmCheckScript
    tmUsageScript
  ];

  # Enable Avahi for network discovery (helps macOS find the server)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };
}
