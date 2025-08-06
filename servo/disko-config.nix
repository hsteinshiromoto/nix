# disko-config.nix
# Disk partitioning configuration for the servo system
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
