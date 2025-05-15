# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Format code: `nix fmt` or `nixpkgs-fmt <file.nix>`
- Build Darwin configuration: `darwin-rebuild switch --flake ~/.config/nix/darwin#MBP2025`
- Update Darwin flake: `nix flake update --flake ~/.config/nix/darwin`
- Test Darwin build: `darwin-rebuild build --flake ~/.config/nix/darwin#MBP2025`
- Build NixOS server: `sudo nixos-rebuild test --flake .#servidor` (use `switch` instead of `test` to apply)
- Update server flake: `nix flake update --flake ~/.config/nix/servo`
- Build custom ISO: `nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./custom_iso.nix`

## Troubleshooting
- If you encounter dependency errors or missing packages, update the flake first
- For "substituteAll is deprecated" warnings, these are from upstream and can be ignored
- When building with `darwin-rebuild`, you may need to run with `sudo` for system changes
- If you encounter nodejs version errors, check for available versions in the latest nixpkgs
- For homebrew issues, ensure the user specified in nix-homebrew.user exists

## Code Style
- Use 2-space indentation for all Nix files
- Group related attributes together in logical sections
- Follow nixpkgs attribute naming conventions (camelCase)
- For input declarations, use clear descriptions of channels and dependencies
- Organize flake inputs with "Core channels" first, followed by specialized inputs
- Prefer explicit version pinning in input URLs (e.g., nixos-24.11)
- Use descriptive variable names that indicate purpose or content
- For system configurations, include informative comments on configuration blocks
- Keep configuration modular with imports when appropriate