# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "servidor"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hsteinshiromoto = {
    isNormalUser = true;
    description = "Humberto STEIN SHIROMOTO";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  # home-manager.users.hsteinshiromoto = import /home/hsteinshiromoto/.config/home-manager/home-common.nix;
  home-manager.users.hsteinshiromoto = { pkgs, ... }: {
	  # Set the home-manager version to match your NixOS version
	  home.stateVersion = "23.11";
	  
	  # Enable home-manager itself
	  programs.home-manager.enable = true;
	  
	  # Enable home-manager's systemd user service
	  systemd.user.startServices = "sd-switch";
	  
	  # Add your home-manager configurations here
	  # For example:
	  # programs.git = {
	  #   enable = true;
	  #   userName = "Your Name";
	  #   userEmail = "your.email@example.com";
	  # };
   };
 
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
	bat
	btop
	cargo
	curl
	git
	eza
	fd
	fzf
	git
	gitflow
	gnupg
	lazygit
	nerdfonts
	neovim
	jetbrains-mono
	neovim
	ripgrep
	starship
	tmux	
	tmuxinator
	vim
	wget
	yazi
	zoxide
	zsh
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
	  enable = true;
	  setSocketVariable = true;
	};


  programs.zsh.enable = true;  # If you use zsh
  programs.zsh.interactiveShellInit = ''
    export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
     export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

  '';
  # List services that you want to enable

  services.tailscale.enable = true;


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
