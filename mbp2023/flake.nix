{
  description = "Nix-darwin MBP2023 System Flake";

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, ... }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
					pkgs.atuin
					pkgs.bat
					pkgs.btop
					pkgs.calcure
					pkgs.claude-code
					pkgs.dua
					pkgs.eza
					pkgs.fd
					pkgs.fzf
					pkgs.gemini-cli
					pkgs.git
					pkgs.git-cliff
					pkgs.gitflow
					pkgs.gnupg
					pkgs.lazygit
					pkgs.lnav
					pkgs.mkalias
					pkgs.nodejs_24
					pkgs.ollama
					pkgs.neovim
					pkgs.pass
					pkgs.ripgrep
					pkgs.ruff
					pkgs.serpl
					pkgs.spotify-player
					pkgs.starship
					pkgs.stow
					pkgs.tmux
					pkgs.tmuxinator
					pkgs.tree
					pkgs.uv
					pkgs.yazi
					pkgs.yq
					pkgs.yubikey-manager
					pkgs.zoxide
        ];

		homebrew = {
			enable = true;
			brews = [
				"mas"
			];
			casks = [
				"balenaetcher"
				"bartender"
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
				"Microsoft OneNote" = 784801555;
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
            home-manager.useUserPackages = true;
            home-manager.users.hsteinshiromoto = ./home.nix;
          }
				];
    };
  };
}
