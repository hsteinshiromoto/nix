# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, pkgsUnstable, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
			./sops.nix                    # <- Comment out this line to remove dependency on sops
			./yubikey.nix
			./network_manager.nix         # <- Comment out this line to remove dependency on sops
			./git-server.nix
			./home-assistant.nix
			./time-machine.nix						# <- Comment out this line to remove dependency on sops
			./media.nix                   # <- Comment out this line to remove dependency on sops
			./mb.nix                      # <- Comment out this line to remove dependency on sops
			./nginx.nix
			./jellyfin.nix
			./transmission.nix
			./backup.nix                  # <- Comment out this line to remove dependency on sops
			./protonvpn.nix               # <- Comment out this line to remove dependency on sops
    ];

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

	# LUKS disk encryption with TPM2 support
	# Enroll TPM2 key with: sudo systemd-cryptenroll --tpm2-device=auto /dev/sda2
	# Passphrase remains as fallback if TPM fails
	boot.initrd = {
		systemd.enable = true;  # Required for TPM2 unlock
		availableKernelModules = [ "tpm_tis" "tpm_crb" ];  # TPM2 kernel modules
		luks.devices."crypted" = {
			device = "/dev/disk/by-partlabel/disk-main-luks";
			crypttabExtraOpts = [ "tpm2-device=auto" ];
			allowDiscards = true;  # Enable TRIM for SSD
		};
	};

	system.autoUpgrade = {
		enable = true;
		allowReboot = true;
		channel = "https://channels.nixos.org/nixos-25.11";
	};

  networking = {
    hostName = "servidor";
		nameservers = [ "8.8.8.8" "1.1.1.1" ];
    networkmanager = {
      enable = true;
      wifi.powersave = false;  # Disable WiFi power management to prevent disconnections
    };

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
						stow
						tmuxinator
			];
      # SSH authorized_keys will be managed by systemd service (see sops.nix)
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
    btop
    cargo
    curl
		disko
		docker-compose
		exfat
    fd
    fzf
    git
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
		openvpn                  # VPN client for ProtonVPN
    pass
		pcsclite
    pkg-config # Build essential
		proton-vpn-cli
    ripgrep
		sops
		ssh-to-age
		systemctl-tui
    tmux
		tree-sitter
		usbutils
		yubikey-personalization  # CLI tools for configuring YubiKey
    yubikey-manager          # Manage YubiKey settings
		yubikey-agent
    yq
    wget
		wirelesstools
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

		hardware.gpgSmartcards.enable = true;

	# Bluetooth support for Intel 9460/9560
	hardware.bluetooth = {
		enable = true;
		powerOnBoot = true;
	};
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
		resolved = {
			enable = true;
			fallbackDns = [ "8.8.8.8" "1.1.1.1" ];
		};
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
      group = "users";
      dataDir = "/home/hsteinshiromoto/syncthing";
      configDir = "/home/hsteinshiromoto/syncthing/.config/syncthing";
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
			wantedBy = ["multi-user.target"];

			serviceConfig = {
				Type = "simple";
				User = "hsteinshiromoto";
				Environment = "PATH=/run/current-system/sw/bin:/usr/bin:/bin";
				ExecStart = "/run/current-system/sw/bin/nvim --headless --listen 0.0.0.0:9000";
				Restart = "always";
				RestartSec = 5;
				WorkingDirectory = "/home/hsteinshiromoto/";
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
  system.stateVersion = "25.11"; # Did you read the comment?

}
