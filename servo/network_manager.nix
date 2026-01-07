{ config, lib, pkgs, ... }:

{
  # Create a NetworkManager connection file with SOPS secrets
  systemd.services.nm-setup-wifi = {
    description = "Setup NetworkManager WiFi connection with SOPS secrets";
    wantedBy = [ "multi-user.target" ];
    after = [ "NetworkManager.service" ];
    
    script = ''
      # Wait for SOPS secrets to be decrypted
      while [ ! -f ${config.sops.secrets."wifi/ssid".path} ] || [ ! -f ${config.sops.secrets."wifi/password".path} ]; do
        echo "Waiting for SOPS secrets to be available..."
        sleep 2
      done

      # Read the secrets
      SSID=$(cat ${config.sops.secrets."wifi/ssid".path})
      PSK=$(cat ${config.sops.secrets."wifi/password".path})

      # Create NetworkManager connection
      ${pkgs.networkmanager}/bin/nmcli connection delete "home-wifi" 2>/dev/null || true
      
      ${pkgs.networkmanager}/bin/nmcli connection add \
        type wifi \
        con-name "home-wifi" \
        ssid "$SSID" \
        wifi-sec.key-mgmt wpa-psk \
        wifi-sec.psk "$PSK" \
        connection.autoconnect true \
        connection.autoconnect-priority 10

      echo "WiFi connection 'home-wifi' configured successfully"
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Run as root to access NetworkManager
      User = "root";
    };
  };

  # Ensure NetworkManager can manage WiFi
  networking.networkmanager.wifi.backend = "wpa_supplicant";
}