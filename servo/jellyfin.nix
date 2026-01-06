# Jellyfin media server configuration
# https://wiki.nixos.org/wiki/Jellyfin

{ config, lib, pkgs, ... }:

let
  mediaPath = "/mnt/media";
in {
  services.jellyfin = {
    enable = true;
    # Open firewall for web interface (port 8096)
    openFirewall = true;
  };

  # Add jellyfin user to the media group for access to media files
  users.users.jellyfin = {
    extraGroups = [ "video" "render" ];
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

  # Ensure Jellyfin service starts after media drive is mounted
  systemd.services.jellyfin = {
    after = [ "mnt-media.mount" ];
    wants = [ "mnt-media.mount" ];
  };
}
