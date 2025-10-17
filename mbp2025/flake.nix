{
  description = "Nix-darwin MBP2025 system flake";

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, ... }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
				pkgs.awscli2
				pkgs.btop
				pkgs.csvlens
				pkgs.doppler
				pkgs.fd
				pkgs.fzf
				pkgs.git
				pkgs.gitflow
				pkgs.go
				pkgs.jira-cli-go
				pkgs.jq
				pkgs.lazygit
				pkgs.lnav
				pkgs.mkalias
				pkgs.neovim
				pkgs.nodejs_24
				pkgs.ollama
				pkgs.pass
				pkgs.ripgrep
				pkgs.ruff
				pkgs.serpl
				pkgs.spotify-player
				pkgs.stow
				pkgs.tmux
				pkgs.tmuxinator
				pkgs.uv
				pkgs.yazi
				pkgs.yq
				pkgs.yubikey-manager
				pkgs.zoxide
      ];
			homebrew = {
				enable = true;
				taps = [
					"gromgit/brewtils"
				];
				brews = [
					"libomp"
					"mas"
					"gromgit/brewtils/taproom"
				];
				casks = [
					"bartender"
					"bitwarden"
					"cursor"
					"dbeaver-community"
					"docker-desktop"
					"drawio"
					"espanso"
					"firefox"
					"figma"
					"ghostty"
					"google-chrome"
					"gpg-suite"
					"karabiner-elements"
					"maccy"
					"microsoft-teams"
					"obsidian"
					"popclip"
					"proton-pass"
					"reader"
					"spotify"
					"the-unarchiver"
					"visual-studio-code"
					"yubico-authenticator"
				];
				onActivation.cleanup = "zap";
				onActivation.autoUpdate = true;
				onActivation.upgrade = true;
				masApps = {
					"Magnet" = 441258766;
					# "Microsoft 365" = 1450038993;
					"Microsoft Excel" = 462058435;
					"Microsoft OneNote" = 784801555;
					"Microsoft Outlook" = 985367838;
					"Microsoft Powerpoint" = 462062816;
					"Microsoft Word" = 462054704;
					"OneDrive" = 823766827;
					"TextSniper - OCR, Copy & Paste" = 1528890965;
					"Theine" = 955848755;
				};
			};
      fonts.packages = [
				pkgs.nerd-fonts.jetbrains-mono
      ];

			nixpkgs.config.allowUnfree = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Set primary user for homebrew and other user-specific options
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
    # $ darwin-rebuild build --flake .#MBP2025
    darwinConfigurations."MBP2025" = nix-darwin.lib.darwinSystem {
      modules = [
				configuration
				nix-homebrew.darwinModules.nix-homebrew {
					nix-homebrew = {
					  enable = true;
						enableRosetta = true;
						user = "hsteinshiromoto";
					 };
				}
				home-manager.darwinModules.home-manager {
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = false;
					home-manager.users.hsteinshiromoto = ./home.nix;
				}
      ];
    };
  };
}
