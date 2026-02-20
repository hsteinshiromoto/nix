# Decrypt a LUKS partition by UUID
# Usage: just decrypt_disk <uuid> [name] [key_file]
# Examples:
#   just decrypt_disk xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   just decrypt_disk xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx mb-crypt /run/secrets/mb_luks_key
decrypt_disk id="833822db-34a3-424d-bc6e-c1895058ccc6" name="mb-crypt" key_file="":
    #!/usr/bin/env bash
    if [ -n "{{key_file}}" ]; then
        sudo cryptsetup open --key-file "{{key_file}}" "/dev/disk/by-uuid/{{id}}" "{{name}}"
    else
        sudo cryptsetup open "/dev/disk/by-uuid/{{id}}" "{{name}}"
    fi

# Mount a decrypted partition
# Usage: just mount_disk [device] [mountpoint]
mount_disk device="/dev/mapper/mb-crypt" mountpoint="/mnt/mb":
    sudo mkdir -p {{mountpoint}}
    sudo mount {{device}} {{mountpoint}}

# Unmount and close a LUKS partition
# Usage: just unmount_disk [mountpoint] [name]
unmount_disk mountpoint="/mnt/mb" name="mb-crypt":
    sudo umount {{mountpoint}}
    sudo cryptsetup close {{name}}
