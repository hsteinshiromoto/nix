{
  description = "Nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nix-darwin.follows = "nix-darwin";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
		pkgs.awscli2
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
		pkgs.maccy
		pkgs.mkalias
		pkgs.nodejs_24
		pkgs.ollama
		pkgs.pass
		pkgs.ripgrep
		pkgs.ruff
		pkgs.starship
		pkgs.stow
		pkgs.tmux
		pkgs.tmuxinator
		pkgs.uv
		pkgs.yazi
		pkgs.yq
		pkgs.zoxide
        ];


      homebrew = {
		enable = true;
		brews = [
			"mas"
			"neovim"
		];
		casks = [
			"cursor"
			"docker"
			"drawio"
			"espanso"
			"firefox"
			"ghostty"
			"google-chrome"
			"hiddenbar"
			"microsoft-teams"
			"obsidian"
			"popclip"
			"spotify"
			"the-unarchiver"
			"visual-studio-code"
		];
		onActivation.cleanup = "zap";
		onActivation.autoUpdate = true;
		onActivation.upgrade = true;
		masApps = {
			"Magnet" = 441258766;
			"Microsoft 365" = 1450038993;
			"Microsoft Excel" = 462058435;
			"Microsoft OneNote" = 784801555;
			"Microsoft Outlook" = 985367838;
			"Microsoft Powerpoint" = 462062816;
			"Microsoft Word" = 462054704;
			"OneDrive" = 823766827;
			"Windows App" = 1295203466;
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

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Required after nix-darwin 2024-05 migration: designate the primary
      # user that runs darwin-rebuild so user-scoped options (homebrew, etc.)
      # are applied correctly.
      system.primaryUser = "hsteinshiromoto";

      # Configure a lightweight on-demand NixOS VM that acts as a local
      # Linux build host. This accelerates Linux-only builds while keeping
      # the developer workflow on macOS.
      nix.linux-builder = {
        enable     = true;
        ephemeral  = true;     # Recreate the VM for every evaluation.
        maxJobs    = 4;        # Parallel build jobs inside the VM.
        config = {
          virtualisation.cores       = 4;
          virtualisation.memorySize  = pkgs.lib.mkForce 8192;   # 8 GiB RAM
          virtualisation.diskSize    = pkgs.lib.mkForce 30720;  # 30 GiB disk
        };
      };

      # Let the Nix daemon know we can build remotely (locally, via the VM).
      nix.distributedBuilds = true;
      nix.buildMachines = [{
        hostName = "localhost";
        system   = "x86_64-linux";
        maxJobs  = 4;
        supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
        sshUser = "builder";
        sshKey  = "/etc/nix/builder_ed25519";
      }];

      programs.ssh.extraConfig = ''
        Host localhost
          Port 31022
      '';
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
