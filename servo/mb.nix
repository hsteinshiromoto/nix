# MB backup drive configuration with LUKS encryption
# External drive (sdb2) for mbp2023 backup storage

{ config, pkgs, lib, ... }:

let
  mbPath = "/mnt/mb";
in {
  # Systemd service to unlock the drive after SOPS decrypts the key
  systemd.services.mb-crypt-unlock = {
    description = "Unlock mb LUKS volume";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" "systemd-udev-settle.service" ];
    wants = [ "sops-nix.service" ];
    requires = [ "systemd-udev-settle.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      # Read UUID from SOPS secret
      UUID_FILE="${config.sops.secrets.mb_sdb2_uuid.path}"
      if [ ! -f "$UUID_FILE" ]; then
        echo "ERROR: UUID secret not found at $UUID_FILE"
        exit 1
      fi
      LUKS_UUID=$(cat "$UUID_FILE" | tr -d '\n')

      # Check if the drive is connected
      if [ ! -e "/dev/disk/by-uuid/$LUKS_UUID" ]; then
        echo "Drive with UUID $LUKS_UUID not found, skipping unlock"
        exit 0
      fi

      # Unlock the LUKS volume if not already unlocked
      if [ ! -e /dev/mapper/mb-crypt ]; then
        ${pkgs.cryptsetup}/bin/cryptsetup open \
          --key-file ${config.sops.secrets.mb_luks_key.path} \
          /dev/disk/by-uuid/$LUKS_UUID mb-crypt
      fi
    '';
  };

  # Mount the decrypted filesystem
  fileSystems.${mbPath} = {
    device = "/dev/mapper/mb-crypt";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=10s" "x-systemd.requires=mb-crypt-unlock.service" "x-systemd.after=mb-crypt-unlock.service" ];
  };
}
