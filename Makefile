.PHONY: servo

iso:
	nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.custom-iso.config.system.build.isoimage

servo:
	sudo nixos-rebuild test --flake .#servidor --impure

25:
	darwin-rebuild switch --flake ~/.config/nix/mbp2025#MBP2025
