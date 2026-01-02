# disko-config.nix
# Disk partitioning configuration for the servo system
#
# Partition layout:
#   ESP:  1GB   - EFI boot partition
#   LUKS: rest  - Encrypted container with LVM inside:
#     - root: 64GB  - System root filesystem
#     - swap: 4GB   - Swap space
#     - git:  32GB  - Git server data (/var/lib/git-server)
#     - home: rest  - User home directories
#
# Minimum disk size required: ~110GB (101GB fixed + some home space)
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";  # Adjust device as needed
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
						luks = {
							size = "100%";
							type = "8300";
							content = {
								type = "luks";
								name = "crypted";
								settings = {
									allowDiscards = true;
								};
								content = {
									type = "lvm_pv";
									vg = "vgpool";
								};
							};
						};
					};
        };
      };
    };
    lvm_vg = {
      vgpool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "64G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          swap = {
            size = "4G";
            content = {
              type = "swap";
            };
          };
          git = {
            size = "32G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/var/lib/git-server";
              mountOptions = [ "defaults" "noatime" ];
            };
          };
          home = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };
        };
      };
    };
  };
}
