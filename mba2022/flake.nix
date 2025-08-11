{
  description = "Nix-darwin MBA2022 System Flake";

	outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
					pkgs.atuin
					pkgs.bat
					pkgs.btop
					pkgs.claude-code
					pkgs.eza
					pkgs.fd
					pkgs.fzf
					pkgs.git
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
					pkgs.starship
					pkgs.stow
					pkgs.tmux
					pkgs.tmuxinator
					pkgs.uv
					# pkgs.vagrant
					pkgs.yazi
					pkgs.yq
					pkgs.zoxide
        ];

		homebrew = {
			enable = true;
			brews = [
				"mas"
			];
			casks = [
				"bartender"
				"discord"
				"espanso"
				"firefox"
				"gpg-suite"
				"ghostty"
				"google-chrome"
				"karabiner-elements"
				"istat-menus"
				"maccy"
				"obsidian"
				"microsoft-teams"
				"popclip"
				"proton-pass"
				"protonvpn"
				"reader"
				"spotify"
				"syncthing"
				"the-unarchiver"
				"utm"
				"waterfox"
				"yubico-authenticator"
			];
			onActivation.cleanup = "zap";
			onActivation.autoUpdate = true;
			onActivation.upgrade = true;
			masApps = {
				"Bitwarden" = 1352778147;
				"Magnet" = 441258766;
				"Microsoft 365" = 1450038993;
				"Microsoft Excel" = 462058435;
				"Microsoft OneNote" = 784801555;
				"Microsoft Outlook" = 985367838;
				"Microsoft Powerpoint" = 462062816;
				"Microsoft Word" = 462054704;
				"OneDrive" = 823766827;
				"Proton Authenticator" = 6741758667;
				"Tailscale" = 1475387142;
				"TextSniper - OCR, Copy & Paste" = 1528890965;
				"Theine" = 955848755;
			#
			       };

		};

			nixpkgs.config.allowUnfree = true;

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

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."MBA2022" = nix-darwin.lib.darwinSystem {
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
				];
    };
  };
}
