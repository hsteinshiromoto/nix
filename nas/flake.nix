{
  description = "NixOS configuration for nas";

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, sops-nix, ... }@inputs:
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
            
            # The following user definition is required by home-manager [1]
            # [1] https://discourse.nixos.org/t/homedirectory-is-note-of-type-path-darwin/57453/6
            users.users.hsteinshiromoto = {
              isNormalUser = true;
              home = "/home/hsteinshiromoto";
              extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
            };
            
            # Set system.stateVersion
            system.stateVersion = "25.05";
            
            # Minimal boot configuration for flake check
            boot.loader.grub.enable = true;
            boot.loader.grub.devices = [ "nodev" ]; # For EFI systems
            
            # Minimal filesystem configuration
            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };
          })

          # Include your main configuration
          # ./configuration.nix
					disko.nixosModules.disko
					# ./disko-config.nix # Do not enable with ./hardware-configuration.nix import in configuration.nix
					sops-nix.nixosModules.sops
					home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
						home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
            # home-manager.users.hsteinshiromoto = ./home.nix;
					}
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
          # ./custom_iso.nix
          # If your custom_iso.nix imports servo/configuration.nix,
          # pkgsUnstable will now be available to it
          
          # Minimal configuration for ISO
          ({ config, pkgs, ... }: {
            system.stateVersion = "25.05";
            
            # ISO-specific boot configuration
            boot.loader.grub.enable = true;
            boot.loader.grub.devices = [ "nodev" ];
            
            # Minimal filesystem for ISO
            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "tmpfs";
            };
          })
        ];
      };

      # Expose the installTest for nixos-anywhere VM testing
      checks.${system}.servidor = self.nixosConfigurations.servidor.config.system.build.installTest;
    };
}
