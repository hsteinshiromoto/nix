# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Build custom ISO: `nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./custom_iso.nix`
- Update Nix flake: `nix flake update --flake . --impure`
- Rebuild NixOS: `nixos-rebuild switch --flake .#servidor`
- Build without switching: `nixos-rebuild build --flake .#servidor`
- Test configuration without switching: `nixos-rebuild test --flake .#servidor --impure`
- Print build plan: `nixos-rebuild build --flake .#servidor --show-trace`
- Darwin rebuild: `darwin-rebuild switch --flake ./mbp2025#MBP2025`
- Build Darwin flake: `darwin-rebuild build --flake ./mbp2025#MBP2025`

## Important Notes
- `nixos-rebuild test/switch/build` commands do NOT repartition disks on existing systems
- Disk partitioning configurations (like disko) only apply during fresh NixOS installation
- To apply partition changes, generate new ISO and reinstall system

## Code Style Guidelines
- Use camelCase for variable/attribute names
- Group related configuration settings together
- Document complex configuration with comments
- Separate hardware-specific configuration
- Organize flakes with clear inputs and outputs structure
- Use descriptive hostnames and system identifiers
- Place system-specific configurations in dedicated directories
- Reference official documentation in comments for non-obvious settings
- For imports, place all imports at the top of files
- Prefer stable packages unless unstable is explicitly needed

## Repository Structure
- `mbp2025/` - macOS configuration using nix-darwin
- `servo/` - NixOS configuration for a server
- Root directory contains shared configuration like custom ISO settings

