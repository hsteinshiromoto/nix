.PHONY: servo

darwin_%: darwin_20$@

nixos_%: nixos_$@

darwin_2022:
	$(eval FLAGS=switch)
	@echo "Running Darwin rebuild with flags ${FLAGS}"
	sudo darwin-rebuild $(FLAGS) --flake .#MBA2022

darwin_2023:
	$(eval FLAGS=switch)
	@echo "Running Darwin rebuild with flags ${FLAGS}"
	sudo darwin-rebuild $(DARWIN_FLAGS) --flake .#MBP2023

darwin_2025:
	$(eval FLAGS=switch)
	@echo "Running Darwin rebuild with flags ${FLAGS}"
	sudo darwin-rebuild $(FLAGS) --flake .#MBP2025

partition:
	@echo "Partitioning disk with disko"

	@echo "Clonning repository into the folder ~/.config/nix ..."
	git clone https://github.com/hsteinshiromoto/nix ~/.config/nix

	@echo "Start partitioning with disko"
	cd ~/.config/nix && sudo nix run github:nix-community/disko -- --mode zap_create_mount /home/nixos/.config/nix/servo/disko-config.nix

nixos_install:
	@echo "Installing nixos from flake"
	sudo nixos-install --flake /home/nixos/.config/nix#servidor
	sudo nixos-enter --root /mnt -c 'passwd hsteinshiromoto'

nixos_rebuild:
	$(eval FLAGS=test)
	@echo "Running nixos-rebuild with flag ${FLAGS}"
	sudo nixos-rebuild $(FLAGS) --flake .#servidor --impure

nixos_iso:
	nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.custom_iso.config.system.build.isoImage
