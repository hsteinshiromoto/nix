{
  description = "Home Manager configuration of hsteinshiromoto";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
		nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ...} @ inputs:
    let
			inherit (self) outputs;
      # Supported systems for your flake packages, shell, etc.
			systems = [
				"aarch64-linux"
				"i686-linux"
				"x86_64-linux"
				"aarch64-darwin"
				"x86_64-darwin"
			];
			# This is a function that generates an attribute by calling a function you
			# pass to it, with each system as an argument
			forAllSystems = nixpkgs.lib.genAttrs systems;

			hosts = [
				{ name = "MacBook-Pro-2023.local"; system = "aarch64-darwin"; username = "hsteinshiromoto"; homeDirectory = "/Users/hsteinshiromoto"; }
				{ name = "servidor"; system = "x86_64-linux"; username = "hsteinshiromoto"; homeDirectory = "/home/hsteinshiromoto"; }
			];
		in {
			# Your custom packages
			# Accessible through 'nix build', 'nix shell', etc
			# packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
			# Formatter for your nix files, available through 'nix fmt'
			# Other options beside 'alejandra' include 'nixpkgs-fmt'
			formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

			# Your custom packages and modifications, exported as overlays
			# overlays = import ./overlays {inherit inputs;};

			# Reusable nixos modules you might want to export
			# These are usually stuff you would upstream into nixpkgs
			# nixosModules = import ./modules/nixos;

			# Reusable home-manager modules you might want to export
			# These are usually stuff you would upstream into home-manager
			# homeManagerModules = import ./modules/home-manager;

			# NixOS configuration entrypoint
			# Available through 'nixos-rebuild --flake .#your-hostname'
			nixosConfigurations = {
				servidor = nixpkgs.lib.nixosSystem {
					specialArgs = {inherit inputs outputs;};
					modules =
						let
								configuration =
									if nixpkgs.lib.strings.hasSuffix "servidor" host.name then
										/etc/nixos/configuration.nix
									else
										(pkgs.writeShellScriptBin "my-hello" ''
									    echo "Not running servidor"
    								'')
							in
							[ configuration ];
						# [
					# 	# > Our main nixos configuration file <
					# 	./nixos/configuration.nix
					# ];
				};
			};

			# Standalone home-manager configuration entrypoint
			# Available through 'home-manager --flake .#your-username@your-hostname'
			homeConfigurations = nixpkgs.lib.listToAttrs (nixpkgs.lib.map (host: {
					name = "${host.username}@${host.name}";
					value = home-manager.lib.homeManagerConfiguration {
						pkgs = nixpkgs.legacyPackages.${host.system};
						extraSpecialArgs = {
							inherit inputs outputs;
							username = host.username;
							homeDirectory = host.homeDirectory;
						};
						modules =
							let
								systemSpecificModule =
									if nixpkgs.lib.strings.hasSuffix "darwin" host.system then
										./home-darwin.nix
									else if nixpkgs.lib.strings.hasSuffix "linux" host.system then
										./home-linux.nix
									else
										throw "Unsupported system: ${host.system}";
							in
							[ ./home-common.nix systemSpecificModule ];
					};
			}) hosts);
    };
}
# ---
# References:
# ---
#   [1] https://github.com/Misterio77/nix-starter-configs/tree/main
#   [2] https://github.com/omerxx/dotfiles/blob/master/nix-darwin/flake.nix
