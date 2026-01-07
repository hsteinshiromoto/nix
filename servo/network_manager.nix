{ config, lib, pkgs, ... }:

{
  # Create a NetworkManager connection file with SOPS secrets
  systemd.services.nm-setup-wifi = {
    description = "Setup NetworkManager WiFi connection with SOPS secrets";
    wantedBy = [ "multi-user.target" ];
    after = [ "NetworkManager.service" ];

    script = ''
      # Wait for SOPS secrets to be decrypted
      while [ ! -f ${config.sops.secrets."wifi/main/ssid".path} ] || [ ! -f ${config.sops.secrets."wifi/main/password".path} ]; do
        echo "Waiting for SOPS secrets to be available..."
        sleep 2
      done

      # Read the secrets
      MAIN_SSID=$(cat ${config.sops.secrets."wifi/main/ssid".path})
      MAIN_PSK=$(cat ${config.sops.secrets."wifi/main/password".path})
			ALT_SSID=$(cat ${config.sops.secrets."wifi/alternative/ssid".path})
      ALT_PSK=$(cat ${config.sops.secrets."wifi/alternative/password".path})

      # Create NetworkManager connection


			# Create NetworkManager connection
      ${pkgs.networkmanager}/bin/nmcli connection delete "alternative" 2>/dev/null || true

      ${pkgs.networkmanager}/bin/nmcli connection add \
        type wifi \
        con-name "alternative" \
        ssid "$ALT_SSID" \
        wifi-sec.key-mgmt wpa-psk \
        wifi-sec.psk "$ALT_PSK" \
        connection.autoconnect true \
        connection.autoconnect-priority 1

			echo "WiFi connection 'alternative' configured successfully"

			${pkgs.networkmanager}/bin/nmcli connection delete "main" 2>/dev/null || true

      ${pkgs.networkmanager}/bin/nmcli connection add \
        type wifi \
        con-name "main" \
        ssid "$MAIN_SSID" \
        wifi-sec.key-mgmt wpa-psk \
        wifi-sec.psk "$MAIN_PSK" \
        connection.autoconnect true \
        connection.autoconnect-priority 10

      echo "WiFi connection 'main' configured successfully"

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
