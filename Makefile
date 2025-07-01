.PHONY: servo

darwin_%: darwin_20$@

nixos_%: nixos_$@

darwin_2022: flake.nix flake.lock mba2022/flake.nix mba2022/flake.lock
	$(eval FLAGS=switch)
	@echo "Running Darwin rebuild with flags ${FLAGS}"
	sudo darwin-rebuild $(FLAGS) --flake .#MBA2022

darwin_2023: flake.nix flake.lock mbp2023/flake.nix mbp2023/flake.lock
	$(eval FLAGS=switch)
	@echo "Running Darwin rebuild with flags ${FLAGS}"
	sudo darwin-rebuild $(DARWIN_FLAGS) --flake .#MBP2023

darwin_2025: flake.nix flake.lock mbp2025/flake.nix mbp2025/flake.lock
	$(eval FLAGS=switch)
	@echo "Running Darwin rebuild with flags ${FLAGS}"
	sudo darwin-rebuild $(FLAGS) --flake .#MBP2025

partition: flake.nix flake.lock servo/disko-config.nix
	@echo "Partitioning disk with disko"

	@echo "Clonning repository into the folder ~/.config/nix ..."
	git clone https://github.com/hsteinshiromoto/nix ~/.config/nix

	@echo "Start partitioning with disko"
	cd ~/.config/nix && sudo nix run github:nix-community/disko -- --mode zap_create_mount /home/nixos/.config/nix/servo/disko-config.nix

nixos_install:
	@echo "Installing nixos from flake"
	sudo nixos-install --flake /home/nixos/.config/nix#servidor
	sudo nixos-enter --root /mnt -c 'passwd hsteinshiromoto'

nixos_rebuild: flake.nix flake.lock servo/flake.nix servo/flake.lock servo/hardware-configuration.nix servo/configuration.nix
	$(eval FLAGS=test)
	@echo "Running nixos-rebuild with flag ${FLAGS}"
	sudo nixos-rebuild $(FLAGS) --flake .#servidor --impure

nixos_iso: flake.nix flake.lock servo/custom_iso.nix
	nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.custom_iso.config.system.build.isoImage
