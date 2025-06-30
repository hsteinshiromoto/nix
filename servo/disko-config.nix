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
							end = "-8G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
						swap = {
              size = "100%";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
					};
        };
      };
    };
  };
}
