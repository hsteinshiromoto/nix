{
  description = "Nix-darwin MBP2023 System Flake";

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, sops-nix, ... }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
					pkgs.btop
					pkgs.calcure
					pkgs.dua
					pkgs.fd
					pkgs.fzf
					pkgs.git-cliff
					pkgs.git-crypt
					pkgs.gocryptfs
					pkgs.lazygit
					pkgs.lnav
					pkgs.mkalias
					pkgs.nodejs_24
					pkgs.neovim
					pkgs.nixd
					(pkgs.pass.withExtensions (exts: [ exts.pass-otp ]))
					pkgs.pcsclite
					pkgs.qrencode
					pkgs.ripgrep
					pkgs.serpl
					pkgs.stow
					pkgs.texliveFull
					pkgs.tmux
					pkgs.tmuxinator
					pkgs.tree
					pkgs.yq
					pkgs.yubikey-manager
        ];

			homebrew = {
				enable = true;
				taps = [
					"gromgit/brewtils"
				];
				brews = [
					"age"
					"age-plugin-yubikey"
					"mas"
					"sops"
					"gromgit/brewtils/taproom"
				];
				casks = [
					"balenaetcher"
					"bartender"
					"bettermouse"
					"cursor"
					"discord"
					"docker-desktop"
					"espanso"
					"firefox"
					"gpg-suite"
					"ghostty"
					"google-chrome"
					"karabiner-elements"
					"maccy"
					"obsidian"
					"oversight"
					"macfuse"
					"microsoft-teams"
					"popclip"
					"proton-drive"
					"proton-pass"
					"protonvpn"
					"reader"
					"spotify"
					"syncthing-app"
					"the-unarchiver"
					"transmission"
					"utm"
					"visual-studio-code"
					"vlc"
					"waterfox"
					"whatsapp"
					"yubico-authenticator"
				];
				onActivation.cleanup = "zap";
				onActivation.autoUpdate = true;
				onActivation.upgrade = true;
				masApps = {
					"Bitwarden" = 1352778147;
					"Kindle" = 302584613;
					"Magnet" = 441258766;
					"Microsoft Excel" = 462058435;
					"Microsoft Outlook" = 985367838;
					"Microsoft Powerpoint" = 462062816;
					"Microsoft Word" = 462054704;
					"OneDrive" = 823766827;
					"Parcel - Delivery Tracking" = 639968404;
					# "Proton Authenticator" = 6741758667; Does not exist as a MacOS App
					# "SimpleLogin - Email alias" = 1494359858; Does not exist as a MacOS App
					"Windows App" = 1295203466;
					"Tailscale" = 1475387142;
					"TextSniper - OCR, Copy & Paste" = 1528890965;
					"Theine" = 955848755;
				#
							 };

			};

			nix.gc = {
				automatic = true;
				options = "--delete-generations +5";
				interval = { Weekday = 0; Hour = 2; Minute = 0; };
			};

			nixpkgs.config.allowUnfree = true;
			nixpkgs.config.allowUnsupportedSystem = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
			system.primaryUser = "hsteinshiromoto";

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

			# The following user definition is required by home-manager [1]
			# [1] https://discourse.nixos.org/t/homedirectory-is-note-of-type-path-darwin/57453/6
			users.users.hsteinshiromoto = {
				name = "hsteinshiromoto";
				home = "/Users/hsteinshiromoto";
					packages = with pkgs; [
						yaziPlugins.lazygit
						jqp
					];

			};

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."MBP2023" = nix-darwin.lib.darwinSystem {

      modules = [
					configuration
					nix-homebrew.darwinModules.nix-homebrew {
						nix-homebrew = {
							enable = true;
							enableRosetta = true;
							user = "hsteinshiromoto";
							autoMigrate = true;
						 };
					}
					home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.hsteinshiromoto = ./home.nix;
            home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
          }
					../nvim.nix
				];
    };
  };
}
