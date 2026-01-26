# Transmission BitTorrent client configuration
{ config, pkgs, ... }:

let
  downloadDir = "/mnt/media/Downloads";
in {
  # Create download directories with proper permissions
  systemd.tmpfiles.rules = [
    "d ${downloadDir} 0775 transmission transmission -"
    "d ${downloadDir}/.incomplete 0775 transmission transmission -"
  ];

  services.transmission = {
    enable = true;
    openRPCPort = true;
    openPeerPorts = true;
    settings = {
      download-dir = downloadDir;
      incomplete-dir-enabled = true;
      incomplete-dir = "${downloadDir}/.incomplete";
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.1,100.*.*.*";
    };
  };

  # Ensure transmission starts after media drive is mounted
  systemd.services.transmission.after = [ "mnt-media.mount" ];
  systemd.services.transmission.requires = [ "mnt-media.mount" ];
}
