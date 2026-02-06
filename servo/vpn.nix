{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    openvpn
  ];

  sops.secrets."vpn_username" = {
    sopsFile = /home/hsteinshiromoto/.config/sops/secrets/servidor/vpn.yaml;
    key = "username";
    mode = "0400";
    owner = "root";
  };

  sops.secrets."vpn_password" = {
    sopsFile = /home/hsteinshiromoto/.config/sops/secrets/servidor/vpn.yaml;
    key = "password";
    mode = "0400";
    owner = "root";
  };

  environment.etc."openvpn/update-resolv-conf" = {
    source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/ProtonVPN/scripts/master/update-resolv-conf.sh";
    };
    mode = "0755";
  };

  # Create credentials file from SOPS secrets and fix .ovpn file
  systemd.services.openvpn-protonvpn-credentials = {
    description = "Create OpenVPN ProtonVPN credentials file";
    wantedBy = [ "multi-user.target" ];
    before = [ "openvpn-protonvpn.service" ];
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
    path = [ pkgs.gnused ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      # Create credentials file with proper newlines
      mkdir -p /etc/openvpn
      printf '%s\n' "$(cat ${config.sops.secrets."vpn_username".path})" > /etc/openvpn/protonvpn-auth.txt
      printf '%s\n' "$(cat ${config.sops.secrets."vpn_password".path})" >> /etc/openvpn/protonvpn-auth.txt
      chmod 400 /etc/openvpn/protonvpn-auth.txt

      # Comment out bare auth-user-pass in .ovpn to prevent interactive prompt
      OVPN_FILE="/home/hsteinshiromoto/.vpn/protonvpn-config.ovpn"
      if [ -f "$OVPN_FILE" ]; then
        sed -i 's/^auth-user-pass[[:space:]]*$/# auth-user-pass/' "$OVPN_FILE"
      fi
    '';
  };

  services.openvpn.servers = {
    protonvpn = {
      config = ''
        config /home/hsteinshiromoto/.vpn/protonvpn-config.ovpn
        auth-user-pass /etc/openvpn/protonvpn-auth.txt
        script-security 2
        up /etc/openvpn/update-resolv-conf
        down /etc/openvpn/update-resolv-conf
      '';
      autoStart = true;
    };
  };

  # Ensure openvpn waits for credentials
  systemd.services.openvpn-protonvpn = {
    after = [ "openvpn-protonvpn-credentials.service" ];
    requires = [ "openvpn-protonvpn-credentials.service" ];
  };
}
