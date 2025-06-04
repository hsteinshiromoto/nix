# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, pkgsUnstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
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
      description = "Humberto STEIN SHIROMOTO";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      packages = with pkgs; [];
      openssh.authorizedKeys.keyFiles = [ "/home/hsteinshiromoto/.ssh/authorized_keys" ];
    };
    users.git = {
      isNormalUser = true;
      home = "/home/git";
      description = "Git user";
      shell = "${pkgs.git}/bin/git-shell";  # Restricts to git commands only
      # openssh.authorizedKeys.keys = [
      #  "ssh-rsa AAAA..." # Add your SSH public key here
      #];
    };
  };

  # Allow unfree packages
  nixpkgs.config = {
		allowUnfree = true;
	};

	fileSystems."/mnt/ssd" = {
		device = "/dev/sdb1";
		fsType = "ext4";
		options = [ "defaults" "nofail" "noatime" ];
	};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    autoconf        # Build essential
    automake        # Build essential
    bat
    btop
    cargo
		pkgsUnstable.claude-code
    curl
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
    stow
    tmux
    tmuxinator
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
            PasswordAuthentication = true;
      };
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
  system.stateVersion = "24.11"; # Did you read the comment?

}
