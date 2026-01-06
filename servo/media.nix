# Media drive configuration with LUKS encryption
# External drive (sdb) for videos and music storage

{ config, pkgs, lib, ... }:

let
  mediaPath = "/mnt/media";
  luksUuid = "03cb0239-e8e9-491e-8460-902cf37a9005";
in {
  # Systemd service to unlock the drive after SOPS decrypts the key
  systemd.services.media-crypt-unlock = {
    description = "Unlock media LUKS volume";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" "systemd-udev-settle.service" ];
    wants = [ "sops-nix.service" ];
    requires = [ "systemd-udev-settle.service" ];
    before = [ "local-fs.target" ];

    unitConfig = {
      # Only run if the drive is connected (checked after udev settles)
      ConditionPathExists = "/dev/disk/by-uuid/${luksUuid}";
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      if [ ! -e /dev/mapper/media-crypt ]; then
        ${pkgs.cryptsetup}/bin/cryptsetup open \
          --key-file ${config.sops.secrets.media_luks_key.path} \
          /dev/disk/by-uuid/${luksUuid} media-crypt
      fi
    '';
  };

  # Mount the decrypted filesystem
  fileSystems.${mediaPath} = {
    device = "/dev/mapper/media-crypt";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=10s" ];
  };
}
