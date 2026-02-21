# Nginx reverse proxy - centralized configuration
# Individual services add their locations via their own .nix files
#
# Usage: Other modules can add locations with:
#   services.nginx.virtualHosts."servidor".locations."/myapp" = { ... };

{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 443 ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."servidor" = {
      forceSSL = true;
      sslCertificate = "/var/lib/nginx/ssl/servidor.crt";
      sslCertificateKey = "/var/lib/nginx/ssl/servidor.key";
    };
  };

  # Generate self-signed certificate on first boot
  systemd.services.nginx-ssl-init = {
    description = "Generate self-signed SSL certificate for nginx";
    wantedBy = [ "nginx.service" ];
    before = [ "nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /var/lib/nginx/ssl
      if [ ! -f /var/lib/nginx/ssl/servidor.crt ]; then
        ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 365 \
          -newkey rsa:2048 \
          -keyout /var/lib/nginx/ssl/servidor.key \
          -out /var/lib/nginx/ssl/servidor.crt \
          -subj "/CN=servidor"
        chown -R nginx:nginx /var/lib/nginx/ssl
        chmod 600 /var/lib/nginx/ssl/servidor.key
      fi
    '';
  };
}
