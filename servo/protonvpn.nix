# ProtonVPN configuration using OpenVPN
# See: https://protonvpn.com/support/linux-openvpn/
{ config, pkgs, lib, ... }:

{
  # OpenVPN client configuration for ProtonVPN
  services.openvpn.servers.protonvpn = {
    config = ''
      client
      dev tun
      proto udp

      # ProtonVPN server - update this with your preferred server
      # Download .ovpn config from: https://account.protonvpn.com/downloads
      remote <SERVER_ADDRESS> 1194

      resolv-retry infinite
      nobind
      persist-key
      persist-tun

      # Certificate and key settings
      remote-cert-tls server
      cipher AES-256-CBC
      auth SHA512

      # Use SOPS-managed credentials file
      auth-user-pass ${config.sops.secrets."protonvpn/credentials".path}

      # ProtonVPN CA certificate (inline)
      <ca>
      # Paste ProtonVPN CA certificate here from your .ovpn file
      </ca>

      # TLS auth key (inline)
      <tls-auth>
      # Paste TLS auth key here from your .ovpn file
      </tls-auth>
      key-direction 1

      verb 3
    '';

    autoStart = false;  # Set to true once configured
    updateResolvConf = true;  # Update DNS when connected
  };

  # Firewall rules for VPN
  networking.firewall = {
    # Allow VPN traffic
    allowedUDPPorts = [ 1194 ];
    # Trust the VPN interface
    trustedInterfaces = [ "tun0" ];
  };
}
