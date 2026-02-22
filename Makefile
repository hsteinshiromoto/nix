.DEFAULT_GOAL := help
.PHONY: help build test

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

## Test a host configuration. Usage: make test HOST=mbp2025
test:
	@host_dir=""; flake_attr=""; \
	case "$(HOST)" in \
		mba2022|mbp2023|mbp2025) host_dir="$(HOST)"; flake_attr="darwinConfigurations.$(HOST).system";; \
		servidor) host_dir="servo"; flake_attr="nixosConfigurations.$(HOST).config.system.build.toplevel";; \
		*) echo "$(RED)[ERROR]$(RESET) Unknown or missing HOST='$(HOST)'. Valid hosts: mba2022, mbp2023, mbp2025, servidor"; exit 1;; \
	esac; \
	echo "$(GREEN)[INFO]$(RESET) Syntax-checking .nix files for $(BOLD)$(YELLOW)$(HOST)$(RESET)..."; \
	for f in $${host_dir}/*.nix common/*.nix flake.nix; do \
		if [ -f "$$f" ]; then \
			nix-instantiate --parse "$$f" > /dev/null || { echo "$(RED)[ERROR]$(RESET) Syntax error in $$f"; exit 1; }; \
		fi; \
	done; \
	echo "$(GREEN)[INFO]$(RESET) Syntax check passed"; \
	echo "$(GREEN)[INFO]$(RESET) Running dry-run build for $(BOLD)$(YELLOW)$(HOST)$(RESET)..."; \
	nix build ".#$${flake_attr}" --dry-run 2>&1; \
	echo "$(GREEN)[INFO]$(RESET) Done"

## Get ISO image via rsync
get_iso:
	rsync -avzL hsteinshiromoto@servidor:/home/hsteinshiromoto/.config/nix/result ./iso

## Update flake.lock
update:
	$(call log_info,Updating flake.lock...)
	nix flake update
	$(call log_info,Done)

## Rebuild a host. Usage: make build HOST=mbp2025 FLAGS=switch
build:
	@case "$(HOST)" in \
		mba2022|mbp2023|mbp2025) \
			flags="$(or $(FLAGS),build)"; \
			echo "$(GREEN)[INFO]$(RESET) Running Darwin rebuild for $(BOLD)$(YELLOW)$(HOST)$(RESET) with flags $(BOLD)$(YELLOW)$${flags}$(RESET)..."; \
			sudo darwin-rebuild $${flags} --flake .#$(HOST) --impure; \
			echo "$(GREEN)[INFO]$(RESET) Done"; \
			;; \
		servidor) \
			flags="$(or $(FLAGS),test)"; \
			echo "$(GREEN)[INFO]$(RESET) Running NixOS rebuild for $(BOLD)$(YELLOW)$(HOST)$(RESET) with flags $(BOLD)$(YELLOW)$${flags}$(RESET)..."; \
			sudo nixos-rebuild $${flags} --flake .#$(HOST) --impure; \
			echo "$(GREEN)[INFO]$(RESET) Done"; \
			;; \
		*) \
			echo "$(RED)[ERROR]$(RESET) Unknown or missing HOST='$(HOST)'. Valid hosts: mba2022, mbp2023, mbp2025, servidor"; \
			exit 1; \
			;; \
	esac

## Run partition the disk using disko. Usage (for repartition the disk): make partition FLAGS=disko
partition: flake.nix flake.lock servo/disko-config.nix
	$(eval FLAGS=mount)
	$(call log_info,Partitioning disk with disko with flag $(BOLD)$(YELLOW)$(FLAGS)$(RESET)...)
	cd ~/.config/nix && sudo nix run github:nix-community/disko -- --mode $(FLAGS) /home/nixos/.config/nix/servo/disko-config.nix
	$(call log_info,Done)

## Install NixOS from flake
nixos_install:
	$(call log_info,Installing NixOS from flake...)
	sudo nixos-install --flake /home/nixos/.config/nix#servidor
	sudo nixos-enter --root /mnt -c 'passwd hsteinshiromoto'

## Generate ISO image from NixOS
nixos_iso: flake.nix flake.lock servo/custom_iso.nix
	nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.custom_iso.config.system.build.isoImage

## Check whether the configuration and disko-config are valid
nixos_anywhere:
	nix run github:nix-community/nixos-anywhere -- --flake .#servidor --vm-test

## Enroll TPM2
nixos_tpm:
	sudo systemd-cryptenroll --tpm2-device=auto /dev/disk/by-partlabel/disk-main-luks

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
