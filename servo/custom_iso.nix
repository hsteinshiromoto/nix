# custom-iso.nix - Minimal ISO for installation (no SOPS dependencies)
{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    (modulesPath + "/installer/cd-dvd/channel.nix")
  ];

  # Disable documentation to speed up build
  documentation.enable = false;
  documentation.nixos.enable = false;

  # Enable flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Network for installation
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # Tools needed for installation
  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
    disko
    parted
    curl
    wget
    gnupg
    sops
    ssh-to-age

    # Build tools for running Makefile and compilation
    gnumake
    gcc
    pkg-config

    networkmanager
    networkmanagerapplet
  ];

  # Enable SSH so you can install remotely
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Set a known root password for installation (change after install)
  users.users.root.initialPassword = "nixos";

  # Enable GPG agent for setting up keys during install
  programs.gnupg.agent.enable = true;

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
