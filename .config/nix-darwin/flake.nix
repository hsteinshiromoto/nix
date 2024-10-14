
{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
	pkgs.btop
	pkgs.stow
	pkgs.vim
	pkgs.zoxide
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
    homeconfig = {pkgs, ...}: {
            # this is internal compatibility configuration 
            # for home-manager, don't change this!
            # home.stateVersion = "23.05";
            # Let home-manager install and manage itself.
            programs.home-manager.enable = true;

            home.packages = with pkgs; [];

            home.sessionVariables = {
                EDITOR = "nvim";
            };
        };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MacBook-Pro-2023
    darwinConfigurations."MacBook-Pro-2023" = nix-darwin.lib.darwinSystem {
      modules = [ 
      	configuration 
	home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
	    home-manager.verbose = true;
            home-manager.users.hsteinshiromoto = homeconfig;
            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
	];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MacBook-Pro-2023".pkgs;
  };
}
