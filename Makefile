.DEFAULT_GOAL := help
.PHONY: help

# Color definitions for logging (similar to nvim-remote.sh)
GREEN := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
RED := $(shell tput setaf 1)
BOLD := $(shell tput bold)
RESET := $(shell tput sgr0)

# Logging functions
log_info = @echo "$(GREEN)[INFO]$(RESET) $(1)"
log_warning = @echo "$(YELLOW)[WARNING]$(RESET) $(1)"
log_error = @echo "$(RED)[ERROR]$(RESET) $(1)"

## Get ISO image via SCP
get_iso:
	scp -LC hsteinshiromoto@servidor:/home/hsteinshiromoto/.config/nix/result .

## Update flake.lock
update:
	$(call log_info,Updating flake.lock...)
	nix flake update
	$(call log_info,Done)

# Run Nix-Darwin flakes
darwin_%: darwin_20$@

# Run NixOS flakes
nixos_%: nixos_$@

## Rebuild nix-darwin mba2022 flake
darwin_2022: flake.nix flake.lock $(shell find servo -type f -name "*.nix")
	$(eval FLAGS=switch)
	$(call log_info,Running Darwin rebuild with flags $(BOLD)$(YELLOW)$(FLAGS)$(RESET)...)
	sudo darwin-rebuild $(FLAGS) --flake .#MBA2022 --impure

## Rebuild nix-darwin mbp2023 flake
darwin_2023: flake.nix flake.lock $(shell find servo -type f -name "*.nix")
	$(eval FLAGS=switch)
	$(call log_info,Running Darwin rebuild with flags $(BOLD)$(YELLOW)$(FLAGS)$(RESET)...)
	sudo darwin-rebuild $(FLAGS) --flake .#MBP2023 --impure

## Rebuild nix-darwin mbp2025 flake
darwin_2025: flake.nix flake.lock $(shell find servo -type f -name "*.nix")
	$(eval FLAGS=switch)
	$(call log_info,Running Darwin rebuild with flags $(BOLD)$(YELLOW)$(FLAGS)$(RESET)...)
	sudo darwin-rebuild $(FLAGS) --flake .#MBP2025 --impure

## Run partition the disk using disko
partition: flake.nix flake.lock servo/disko-config.nix
	$(call log_info,Partitioning disk with disko...)
	cd ~/.config/nix && sudo nix run github:nix-community/disko -- --mode zap_create_mount /home/nixos/.config/nix/servo/disko-config.nix
	$(call log_info,Done)

## Install NixOS from flake
nixos_install:
	$(call log_info,Installing NixOS from flake...)
	sudo nixos-install --flake /home/nixos/.config/nix#servidor
	sudo nixos-enter --root /mnt -c 'passwd hsteinshiromoto'

## Rebuild NixOS from flake
nixos_rebuild: flake.nix flake.lock $(shell find servo -type f ! -name "*.md")
	$(eval FLAGS=test)
	$(call log_info,Running nixos-rebuild with flag $(BOLD)$(YELLOW)$(FLAGS)$(RESET)...)
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
	@echo "$(BOLD)Available rules:$(RESET)"
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
