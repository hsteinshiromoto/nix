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

  services.openvpn.servers = {
    protonvpn = {
      config = ''
        config /home/hsteinshiromoto/.vpn/protonvpn-config.ovpn
        script-security 2
        up /etc/openvpn/update-resolv-conf
        down /etc/openvpn/update-resolv-conf
      '';
      authUserPass = {
        username = config.sops.secrets."vpn_username".path;
        password = config.sops.secrets."vpn_password".path;
      };
      autoStart = true;
    };
  };
}
