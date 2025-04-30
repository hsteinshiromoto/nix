{
  description = "Nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
		pkgs.bat
		pkgs.btop
		pkgs.eza
		pkgs.fzf
		pkgs.git
		pkgs.gitflow
		pkgs.gnupg
		pkgs.lazygit
		pkgs.mkalias
		pkgs.nodejs_23
		pkgs.starship
		pkgs.stow
		pkgs.tmux
		pkgs.tmuxinator
		pkgs.uv
		pkgs.yazi
		pkgs.zoxide
        ];


      homebrew = {
		enable = true;
		brews = [
			"mas"
			"neovim"
		];
		casks = [
			"docker"
			"firefox"
			"ghostty"
			"microsoft-teams"
			"obsidian"
			"the-unarchiver"
			"visual-studio-code"
		];
		onActivation.cleanup = "zap";
		onActivation.autoUpdate = true;
		onActivation.upgrade = true;
		masApps = {
			"Microsoft 365" = 1450038993;
			"Microsoft Excel" = 462058435;
			"Microsoft OneNote" = 784801555;
			"Microsoft Outlook" = 985367838;
			"Microsoft Powerpoint" = 462062816;
			"Microsoft Word" = 462054704;
			"OneDrive" = 823766827;
			"Windows App" = 1295203466;

	        };

	};
      fonts.packages = [
	pkgs.nerd-fonts.jetbrains-mono
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MBP2025
    darwinConfigurations."MBP2025" = nix-darwin.lib.darwinSystem {
      modules = [ configuration
	nix-homebrew.darwinModules.nix-homebrew
	{
		nix-homebrew = {
			 enable = true;
			enableRosetta = true;
			user = "hsteinshiromoto";
		 };
	}
      ];
    };
  };
}
