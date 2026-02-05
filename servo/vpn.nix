{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    openvpn
  ];

  services.openvpn.servers = {
    protonvpn = {
      config = ''
        config /home/hsteinshiromoto/.vpn/protonvpn-config.ovpn
      '';
      authUserPass = {
        username = "/etc/nixos/protonvpn.auth";
      };
      autoStart = false;
    };
  };
}
