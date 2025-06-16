{
  description = "Multi-system Nix configuration";

  inputs = {
    # Core channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Darwin inputs
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

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

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-darwin, home-manager, disko, ... }@inputs:
  let
    darwinSystem = "aarch64-darwin";
    linuxSystem = "x86_64-linux";

    servo-flake = import ./servo/flake.nix;
    servo-outputs = servo-flake.outputs inputs;
  in
  {
    # Re-export the configurations from each system flake
    nixosConfigurations = servo-outputs.nixosConfigurations;
    
    # Add formatter for convenience
    formatter = {
      "${darwinSystem}" = nixpkgs-unstable.legacyPackages.${darwinSystem}.nixpkgs-fmt;
      "${linuxSystem}" = nixpkgs.legacyPackages.${linuxSystem}.nixpkgs-fmt;
    };
  };
}