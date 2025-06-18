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

    # Local flakes
    darwin-config.url = "path:./mbp2025";
    darwin-config.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
      nix-darwin.follows = "nix-darwin";
      nix-homebrew.follows = "nix-homebrew";
    };

    servo-config.url = "path:./servo";
    servo-config.inputs = {
      nixpkgs.follows = "nixpkgs";
      nixpkgs-unstable.follows = "nixpkgs-unstable";
      home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-darwin, darwin-config, servo-config, ... }:
  let
    darwinSystem = "aarch64-darwin";
    linuxSystem = "x86_64-linux";
  in
  {
    # Re-export the configurations from each system flake
    darwinConfigurations = darwin-config.darwinConfigurations;
    nixosConfigurations = servo-config.nixosConfigurations;
    
    # Add formatter for convenience
    formatter = {
      "${darwinSystem}" = nixpkgs-unstable.legacyPackages.${darwinSystem}.nixpkgs-fmt;
      "${linuxSystem}" = nixpkgs.legacyPackages.${linuxSystem}.nixpkgs-fmt;
    };
  };
}