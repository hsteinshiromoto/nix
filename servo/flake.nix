{
  description = "NixOS configuration for servidor";

  inputs = {
    # Core channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

		disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, ... }@inputs:
    let
      system = "x86_64-linux"; # Adjust if you're using a different architecture

      # Configure the unstable overlay
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Import your main configuration with appropriate overlays
      lib = nixpkgs.lib;
    in {
      nixosConfigurations.servidor = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit pkgsUnstable;
        };
        modules = [
          # Apply the unstable overlay
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [
              (final: prev: {
                unstable = pkgsUnstable;
              })
            ];
          })

          # Include your main configuration
          ./configuration.nix

          # Include Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Define your home-manager configurations here, or import them
            # home-manager.users.hsteinshiromoto = import ./home.nix;
          }

					disko.nixosModules.disko
					# ./disko-config.nix
        ];
      };
    };
}
