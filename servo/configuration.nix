# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, pkgsUnstable, lib, ... }:

let
  # Shared SSH authorized keys for both regular user and git server
  sharedAuthorizedKeys =
    lib.optionals (builtins.pathExists (toString ./.ssh/authorized_keys))
      [ (builtins.readFile ./.ssh/authorized_keys) ];
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
			./yubikey.nix
			./wifi.nix
		./git-server.nix
    ];

	# SOPS configuration for secrets management
	sops = {
		defaultSopsFile = /home/hsteinshiromoto/.config/sops/wifi.yaml;
		defaultSopsFormat = "yaml";
		age = {
			keyFile = "/home/hsteinshiromoto/.config/sops/keys/age";
			generateKey = false;
		};
		secrets = {
			"wifi/ssid" = {};
			"wifi/password" = {};
			"ssh/authorized_keys" = {};
		};
	};

	nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

		# Manual garbage collection - we'll use a custom service below
		gc = {
			automatic = false;
		};

		# Additional Nix settings for space management
		settings = {
			# Automatically optimize store by hardlinking identical files
			auto-optimise-store = true;
			# Warn when free space is below 1GB
			min-free = 1073741824; # 1GB
			# Keep building until only 512MB free space left
			max-free = 536870912; # 512MB
		};
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

	# Limit boot menu entries to last 3 generations
	boot.loader.systemd-boot.configurationLimit = 3;

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
      allowedTCPPorts = [ 22 8384 22000 55666 9000 ];
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
      extraGroups = [ "networkmanager" "wheel" "docker" "sudo" "pcscd" "plugdev"];
      packages = with pkgs; [
						atuin
						pkgsUnstable.claude-code
						stow
						tmuxinator
			];
      openssh.authorizedKeys.keys = sharedAuthorizedKeys;
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
		docker-compose
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
		libfido2                 # Support for FIDO2/WebAuthn
    libiconv    # Build essential
    libtool     # Build essential
    networkmanager
    networkmanagerapplet  # GUI for NetworkManager
    pkgsUnstable.neovim
    nodejs
		ntfs3g
		opensc                   # Smart card support
    pass
		pcsclite
    pkg-config # Build essential
    ripgrep
		sops
    starship
		systemctl-tui
    tmux
		usbutils
    uv
    yazi
		yubikey-personalization  # CLI tools for configuring YubiKey
    yubikey-manager          # Manage YubiKey settings
		yubikey-agent
    yq
    wget
    zoxide
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

		hardware.gpgSmartcards.enable = true;
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
    };
    tailscale = {
      enable = true;
    };
    syncthing = {
      enable = true;
			user = "hsteinshiromoto";
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
		udev.packages = with pkgs; [ yubikey-personalization ];
    pcscd.enable = true;
  };

	systemd.services = {
		nvimd = {
			enable = true;
			description = "Neovim server";
			after = ["network.target"];
			wantedBy = ["default.target"];

			serviceConfig = {
				Type = "simple";
				ExecStart = "/run/current-system/sw/bin/nvim --headless --listen 0.0.0.0:9000";
				Restart="always";
				RestartSec=5;
				WorkingDirectory="/home/hsteinshiromoto/";
			};
		};

		# Custom garbage collection service to keep only last 3 generations
		nixGcKeepLast3 = {
			description = "Nix garbage collection keeping only last 3 generations";
			serviceConfig = {
				Type = "oneshot";
				User = "root";
			};
			script = ''
				# Delete old system generations, keeping last 3
				${pkgs.nix}/bin/nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system

				# Delete old user generations, keeping last 3
				for profile in /nix/var/nix/profiles/per-user/*/profile; do
					if [ -e "$profile" ]; then
						${pkgs.nix}/bin/nix-env --delete-generations +3 --profile "$profile"
					fi
				done

				# Run garbage collection
				${pkgs.nix}/bin/nix-collect-garbage

				# Optimize store
				${pkgs.nix}/bin/nix-store --optimize
			'';
		};
	};

	# Timer to run garbage collection daily
	systemd.timers.nixGcKeepLast3 = {
		wantedBy = [ "timers.target" ];
		timerConfig = {
			OnCalendar = "daily";
			Persistent = true;
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
