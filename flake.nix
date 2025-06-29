{
  description = "Multi-system Nix configuration";

  inputs = {
    # Core channels
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Darwin inputs
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-darwin, nix-homebrew, home-manager, disko, ... }@inputs:
  let
    darwinSystem = "aarch64-darwin";
    linuxSystem = "x86_64-linux";

    servo-flake = import ./servo/flake.nix;
    servo-outputs = servo-flake.outputs {
      inherit self nixpkgs nixpkgs-unstable home-manager;
    };

    mbp2023-flake = import ./mbp2023/flake.nix;
    mbp2023-outputs = mbp2023-flake.outputs {
      inherit self nix-darwin nix-homebrew;
      nixpkgs = nixpkgs-unstable;
    };

    mba2022-flake = import ./mba2022/flake.nix;
    mba2022-outputs = mba2022-flake.outputs {
      inherit self nix-darwin nix-homebrew;
      nixpkgs = nixpkgs-unstable;
    };

    mbp2025-flake = import ./mbp2025/flake.nix;
    mbp2025-outputs = mbp2025-flake.outputs {
      inherit self nix-darwin nix-homebrew;
      nixpkgs = nixpkgs-unstable;
    };

  in
  {
    # Re-export the configurations from each system flake
    nixosConfigurations = servo-outputs.nixosConfigurations;
    darwinConfigurations =
      mbp2023-outputs.darwinConfigurations //
      mba2022-outputs.darwinConfigurations //
      mbp2025-outputs.darwinConfigurations;

    # Add formatter for convenience
    formatter = {
      "${darwinSystem}" = nixpkgs-unstable.legacyPackages.${darwinSystem}.nixpkgs-fmt;
      "${linuxSystem}" = nixpkgs.legacyPackages.${linuxSystem}.nixpkgs-fmt;
    };
  };
}
