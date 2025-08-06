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
						root = {
							size = "64G";
							type = "8300";
							content = {
								type = "luks";
								name = "cryptroot";
								settings = {
									allowDiscards = true;
								};
								content = {
									type = "filesystem";
									format = "ext4";
									mountpoint = "/";
								};
							};
						};
						swap = {
							size = "4G";
							type = "8200";
							content = {
								type = "luks";
								name = "cryptswap";
								settings = {
									allowDiscards = true;
								};
								content = {
									type = "swap";
								};
							};
						};
						home = {
							size = "100%";
							type = "8300";
							content = {
								type = "luks";
								name = "crypthome";
								settings = {
									allowDiscards = true;
								};
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
    };
  };
}
