{
  description = "NixOS configuration for servidor";

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
					disko.nixosModules.disko
					./disko-config.nix # Do not enable with ./hardware-configuration.nix import in configuration.nix
        ];
      };

		# ADD THIS NEW CONFIGURATION for the ISO:
      nixosConfigurations.custom_iso = nixpkgs.lib.nixosSystem {
        inherit system;

				specialArgs = {
          inherit pkgsUnstable;
          inherit inputs;  # if you need other inputs
        };

        modules = [
          ./custom_iso.nix
          # If your custom_iso.nix imports servo/configuration.nix,
          # pkgsUnstable will now be available to it
        ];
      };

      # Expose the installTest for nixos-anywhere VM testing
      checks.${system}.servidor = self.nixosConfigurations.servidor.config.system.build.installTest;
    };
}
