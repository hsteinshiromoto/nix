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

  services.openvpn.servers = {
    protonvpn = {
      config = ''
        config /home/hsteinshiromoto/.vpn/protonvpn-config.ovpn
      '';
      authUserPass = {
        username = config.sops.secrets."vpn_username".path;
      };
      autoStart = false;
    };
  };
}
