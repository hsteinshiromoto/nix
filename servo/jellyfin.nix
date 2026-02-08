# Jellyfin media server configuration
# https://wiki.nixos.org/wiki/Jellyfin

{ config, lib, pkgs, ... }:

let
  mediaPath = "/mnt/media";
  mediaDirs = [ "/mnt/media/tv" "/mnt/media/movies" "/mnt/media/music" ];
in {
  services.jellyfin = {
    enable = true;
    # Open firewall for web interface (port 8096)
    openFirewall = true;
  };

  # Create media group for shared access to media files
  users.groups.media = {};

  # Add jellyfin user to groups for media access and hardware acceleration
  users.users.jellyfin = {
    extraGroups = [ "video" "render" "media" ];
  };

  # Set media directory permissions after mount
  systemd.services.jellyfin-media-permissions = {
    description = "Set media directory permissions for Jellyfin";
    after = [ "mnt-media.mount" ];
    requires = [ "mnt-media.mount" ];
    before = [ "jellyfin.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for dir in ${lib.concatStringsSep " " mediaDirs}; do
        if [ -d "$dir" ]; then
          ${pkgs.coreutils}/bin/chgrp -R media "$dir"
          ${pkgs.coreutils}/bin/chmod -R g+rX "$dir"
        fi
      done
    '';
  };

  # Intel hardware acceleration (VAAPI)
  # Server uses Intel CPU per hardware-configuration.nix
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver    # VAAPI driver for Broadwell and newer
      intel-vaapi-driver    # VAAPI driver for older Intel GPUs
      libva-vdpau-driver    # VDPAU backend for VAAPI (formerly vaapiVdpau)
      libvdpau-va-gl        # OpenGL/VAAPI backend for VDPAU
    ];
  };

  # Set VAAPI driver for Jellyfin service
  systemd.services.jellyfin.environment = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Jellyfin-related packages
  environment.systemPackages = with pkgs; [
    jellyfin-ffmpeg       # FFmpeg build optimized for Jellyfin
  ];

  # Symlinks from default Jellyfin library paths to actual media locations
  # This allows Jellyfin's default library configuration to find media
  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin/root/default 0755 jellyfin jellyfin -"
    "L+ /var/lib/jellyfin/root/default/Movies - - - - /mnt/media/movies"
    "L+ /var/lib/jellyfin/root/default/TV - - - - /mnt/media/tv"
    "L+ /var/lib/jellyfin/root/default/Music - - - - /mnt/media/music"
  ];

  # Ensure Jellyfin service starts after media drive is mounted
  systemd.services.jellyfin = {
    after = [ "mnt-media.mount" ];
    wants = [ "mnt-media.mount" ];
  };

  # Nginx reverse proxy location for Jellyfin
  # IMPORTANT: After deployment, configure Jellyfin's Base URL in dashboard:
  # Settings > Networking > Base URL = /jellyfin
  services.nginx.virtualHosts."servidor".locations."/jellyfin" = {
    proxyPass = "http://127.0.0.1:8096";
    proxyWebsockets = true;
    extraConfig = ''
      proxy_buffering off;
    '';
  };
}
