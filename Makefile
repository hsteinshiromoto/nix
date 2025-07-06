.DEFAULT_GOAL := help
.PHONY: help

# Run Nix-Darwin flakes
darwin_%: darwin_20$@

# Run NixOS flakes
nixos_%: nixos_$@

## Rebuild nix-darwin mba2022 flake
darwin_2022: flake.nix flake.lock mba2022/flake.nix mba2022/flake.lock
	$(eval FLAGS=switch)
	@echo "Running Darwin rebuild with flags ${FLAGS}"
	sudo darwin-rebuild $(FLAGS) --flake .#MBA2022

## Rebuild nix-darwin mbp2023 flake
darwin_2023: flake.nix flake.lock mbp2023/flake.nix mbp2023/flake.lock
	$(eval FLAGS=switch)
	@echo "Running Darwin rebuild with flags ${FLAGS}"
	sudo darwin-rebuild $(FLAGS) --flake .#MBP2023 --impure

## Rebuild nix-darwin mbp2025 flake
darwin_2025: flake.nix flake.lock mbp2025/flake.nix mbp2025/flake.lock
	$(eval FLAGS=switch)
	@echo "Running Darwin rebuild with flags ${FLAGS}"
	sudo darwin-rebuild $(FLAGS) --flake .#MBP2025

## Run partition the disk using disko
partition: flake.nix flake.lock servo/disko-config.nix
	@echo "Partitioning disk with disko"

	@echo "Clonning repository into the folder ~/.config/nix ..."
	git clone https://github.com/hsteinshiromoto/nix ~/.config/nix

	@echo "Start partitioning with disko"
	cd ~/.config/nix && sudo nix run github:nix-community/disko -- --mode zap_create_mount /home/nixos/.config/nix/servo/disko-config.nix

## Install NixOS from flake
nixos_install:
	@echo "Installing nixos from flake"
	sudo nixos-install --flake /home/nixos/.config/nix#servidor
	sudo nixos-enter --root /mnt -c 'passwd hsteinshiromoto'

## Rebuild NixOS from flake
nixos_rebuild: flake.nix flake.lock servo/flake.nix servo/flake.lock servo/hardware-configuration.nix servo/configuration.nix
	$(eval FLAGS=test)
	@echo "Running nixos-rebuild with flag ${FLAGS}"
	sudo nixos-rebuild $(FLAGS) --flake .#servidor --impure

## Generate ISO image from NixOS
nixos_iso: flake.nix flake.lock servo/custom_iso.nix
	nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.custom_iso.config.system.build.isoImage

## Check whether the configuration and disko-config are valid
nixos_anywhere:
	nix run github:nix-community/nixos-anywhere -- --flake .#servidor --vm-test

# ---
# Self Documenting Commands
# ---

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>

help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
