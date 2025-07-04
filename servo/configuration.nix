# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, pkgsUnstable, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

	nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

		gc = {
			automatic = true;
			dates = "weekly";
			options = "--delete-older-than +5";
		};
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

	system.autoUpgrade = {
		enable = true;
		allowReboot = true;
		channel = "https://channels.nixos.org/nixos-25.05";
	};

  networking = {
    hostName = "servidor";
    networkmanager.enable = true;

    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 8384 22000 55666 ];
      allowedUDPPorts = [ 21027 22000 ];
    };

  }; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Define a user account. Don't forget to set a password with 'passwd'.
  users = {
    users.hsteinshiromoto = {
      isNormalUser = true;
			shell = pkgs.zsh;
      description = "Humberto STEIN SHIROMOTO";
      extraGroups = [ "networkmanager" "wheel" "docker" "sudo"];
      packages = with pkgs; [
						atuin
						pkgsUnstable.claude-code
						stow
						tmuxinator
			];
      openssh.authorizedKeys.keys =
        lib.optionals (builtins.pathExists (toString ./.ssh/authorized_keys))
          [ (builtins.readFile ./.ssh/authorized_keys) ];
    };
		groups.git = {};
    users.git = {
      isNormalUser = true;
			group = "git";
			home = "/var/lib/git-server";
      description = "Git user";
      shell = "${pkgs.git}/bin/git-shell";  # Restricts to git commands only
			# To use `authorized_keys` file:
			# 	1. create the ssh folder under `/var/lib/git-server` (ie `sudo mkdir -p /var/lib/git-server/.ssh`).
			#		2. Add the `authorized_keys` file to `/var/lib/git-server/.ssh`.
			#   3. In the server, create a repo with the command `sudo -u git bash -c "git init --bare ~/<repo_slug>.git"`
			#		4. Set the local repo `origin` with the command `git remote add origin git@<ip>:<repo_slug>.git`
			# References:
			# 	[1] https://nixos.wiki/wiki/Git#Serve_Git_repos_via_SSH
      openssh.authorizedKeys.keys =
				lib.optionals (builtins.pathExists (toString ./.ssh/authorized_keys))
          [ (builtins.readFile ./.ssh/authorized_keys) ];
    };
  };

  # Allow unfree packages
		nixpkgs.config = {
		allowUnfree = true;
	};

	# Enable disko for installation
	# disko.enableConfig = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    autoconf        # Build essential
    automake        # Build essential
    bat
    btop
    cargo
    curl
		disko
		exfat
    eza
    fd
    fzf
    git
    gitflow
    gcc         # Build essential
    gnumake     # Build essential
		parted
    jetbrains-mono
    lazygit
    libiconv    # Build essential
    libtool     # Build essential
    networkmanager
    networkmanagerapplet  # GUI for NetworkManager
    pkgsUnstable.neovim
    nodejs
		ntfs3g
    pass
    pkg-config # Build essential
    ripgrep
    starship
    tmux
    uv
    yazi
    yq
    wget
    zoxide
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
   programs = {
    gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
    };
    zsh = {
      enable = true;
      interactiveShellInit = ''
        export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
      '';
    };
    neovim = {
       enable = true;
       defaultEditor = true;
    };
  };


  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services = {
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
				PasswordAuthentication = false;
				AcceptEnv = "$TMUX";
      };
			extraConfig = ''
      Match user git
        AllowTcpForwarding no
        AllowAgentForwarding no
        PasswordAuthentication no
        PermitTTY no
        X11Forwarding no
    '';
    };
    tailscale = {
      enable = true;
    };
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
      settings.gui = {
        https = true;
      #  user = "hsteinshiromoto";
      };
    };
    xserver.xkb = {
      layout = "us";
      variant = "";
      };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
