# Servo Backup Configuration

Automated backup using borgbackup to LUKS-encrypted external drive.

## Backup Flow

```
systemd timer (daily)
      |
      v
borgbackup-job-server-backup.service
      |
      v
Reads passphrase from SOPS secret
      |
      v
borg create -> /mnt/backup/borg
      |
      v
borg prune (keeps 7 daily, 4 weekly, 6 monthly)
```

## What Gets Backed Up

| Path | Contents |
|------|----------|
| `/home` | User data |
| `/var` | Application state, databases, containers |

## What's Excluded

- `/var/cache`, `/var/tmp` - temporary files
- `/var/lib/docker` - container layers (can be rebuilt)
- `/var/log/journal` - logs
- `**/.cache`, `**/node_modules`, `**/__pycache__` - regeneratable

## Useful Commands

```bash
# Check backup timer status
systemctl status borgbackup-job-server-backup.timer

# Run backup manually
sudo systemctl start borgbackup-job-server-backup.service

# List backups
sudo BORG_PASSPHRASE=$(sudo cat /run/secrets/backup_borg_passphrase) \
  borg list /mnt/backup/borg

# Check backup size
sudo du -sh /mnt/backup/borg
```

## Restore Examples

```bash
# List files in latest backup
sudo BORG_PASSPHRASE=$(sudo cat /run/secrets/backup_borg_passphrase) \
  borg list /mnt/backup/borg::ARCHIVE_NAME

# Restore specific file
sudo BORG_PASSPHRASE=$(sudo cat /run/secrets/backup_borg_passphrase) \
  borg extract /mnt/backup/borg::ARCHIVE_NAME home/user/important-file

# Restore entire directory
sudo BORG_PASSPHRASE=$(sudo cat /run/secrets/backup_borg_passphrase) \
  borg extract /mnt/backup/borg::ARCHIVE_NAME home/
```

## Drive Configuration

- Mount point: `/mnt/backup`
- Encryption: LUKS + borg repokey-blake2
- Filesystem: ext4
- Boot stage: Stage 2 (systemd, not initrd)
