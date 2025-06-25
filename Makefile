iso:
	nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.custom-iso.config.system.build.isoimage

