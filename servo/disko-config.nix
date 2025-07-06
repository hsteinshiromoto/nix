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
							content = {
								type = "filesystem";
								format = "ext4";
								mountpoint = "/";
							};
						};
						home = {
							size = "100%";
							content = {
								type = "filesystem";
								format = "ext4";
								mountpoint = "/home";
							};
						};
						swap = {
							size = "4G";
							content = {
								type = "swap";
							};
						};
					};
        };
      };
    };
  };
}
