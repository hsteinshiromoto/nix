# Backup configuration with borgbackup
# External drive for server backups with LUKS encryption
# Mounting occurs in stage 2 via systemd service (not initrd)

{ config, pkgs, lib, ... }:

let
  backupPath = "/mnt/backup";
  # TODO: Replace with actual UUID from: sudo blkid /dev/sdX
  luksUuid = "a7aef982-a144-4080-bae4-f3f2af9ce906";
in {
  # SOPS secrets for backup
  sops.secrets = {
    "backup_luks_key" = {
      sopsFile = /home/hsteinshiromoto/.config/sops/secrets/servidor/backup.yaml;
      key = "luks_key";
      mode = "0400";
      owner = "root";
    };
    "backup_borg_passphrase" = {
      sopsFile = /home/hsteinshiromoto/.config/sops/secrets/servidor/backup.yaml;
      key = "borg_passphrase";
      mode = "0400";
      owner = "root";
    };
  };
  # Systemd service to unlock the backup drive after SOPS decrypts the key
  systemd.services.backup-crypt-unlock = {
    description = "Unlock backup LUKS volume";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" "systemd-udev-settle.service" ];
    wants = [ "sops-nix.service" ];
    requires = [ "systemd-udev-settle.service" ];

    unitConfig = {
      # Only run if the drive is connected (checked after udev settles)
      ConditionPathExists = "/dev/disk/by-uuid/${luksUuid}";
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      if [ ! -e /dev/mapper/backup-crypt ]; then
        ${pkgs.cryptsetup}/bin/cryptsetup open \
          --key-file ${config.sops.secrets.backup_luks_key.path} \
          /dev/disk/by-uuid/${luksUuid} backup-crypt
      fi
    '';
  };

  # Mount the decrypted filesystem (stage 2, with nofail for optional drive)
  fileSystems.${backupPath} = {
    device = "/dev/mapper/backup-crypt";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.device-timeout=10s"
      "x-systemd.requires=backup-crypt-unlock.service"
      "x-systemd.after=backup-crypt-unlock.service"
    ];
  };

  # Auto-initialize borg repository if it doesn't exist
  systemd.services.borg-repo-init = {
    description = "Initialize borg backup repository";
    wantedBy = [ "multi-user.target" ];
    after = [ "mnt-backup.mount" "sops-nix.service" ];
    requires = [ "mnt-backup.mount" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      if [ ! -d "${backupPath}/borg" ]; then
        BORG_PASSPHRASE=$(cat ${config.sops.secrets.backup_borg_passphrase.path})
        export BORG_PASSPHRASE
        ${pkgs.borgbackup}/bin/borg init --encryption=repokey-blake2 ${backupPath}/borg
      fi
    '';
  };

  # Borgbackup configuration
  services.borgbackup.jobs.server-backup = {
    paths = [ "/home" "/var" ];
    exclude = [
      "/var/cache"
      "/var/tmp"
      "/var/lib/docker"
      "/var/log/journal"
      "**/.cache"
      "**/node_modules"
      "**/__pycache__"
    ];
    repo = "${backupPath}/borg";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.sops.secrets.backup_borg_passphrase.path}";
    };
    compression = "auto,zstd";
    startAt = "daily";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
  };
}
