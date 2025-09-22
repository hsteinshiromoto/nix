# YubiKey/GPG Smart Card Configuration Fix
# Add this to your imports in configuration.nix or merge with your existing config

{ config, pkgs, lib, ... }:

{
  # Disable yubikey-agent as it conflicts with GPG's direct smart card access
  services.yubikey-agent.enable = false;

  # Ensure pcscd is properly configured
  services.pcscd = {
    enable = true;
    plugins = [ pkgs.ccid ];
  };

  # Override pcscd service to run as root (fixes permission issues)
  systemd.services.pcscd = {
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /run/pcscd";
      User = lib.mkForce "root";
      Group = lib.mkForce "root";
    };
  };

  # Alternative polkit configuration that's more permissive
  security.polkit.extraConfig = lib.mkForce ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.debian.pcsc-lite.access_card" ||
           action.id == "org.debian.pcsc-lite.access_pcsc") &&
          subject.user == "hsteinshiromoto") {
        return polkit.Result.YES;
      }
    });
  '';

  # Ensure GPG agent is properly configured
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # Add pcsc-tools for debugging
  environment.systemPackages = with pkgs; [
    pcsc-tools  # Provides pcsc_scan for testing
  ];
}

