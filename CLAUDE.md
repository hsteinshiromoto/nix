# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

### Building ISOs on macOS
- Build x86_64 ISO: `./build-iso.sh` (quick build)
- Build x86_64 ISO with monitoring: `./build-iso-monitor.sh` (shows progress and auto-copies ISO)
- Note: Building x86_64 ISOs on ARM64 Macs uses QEMU emulation via Docker

### NixOS Commands
- Update Nix flake: `nix flake update --flake . --impure`
- Rebuild NixOS: `nixos-rebuild switch --flake .#servidor`
- Build without switching: `nixos-rebuild build --flake .#servidor`
- Test configuration without switching: `nixos-rebuild test --flake .#servidor --impure`
- Print build plan: `nixos-rebuild build --flake .#servidor --show-trace`

### Darwin Commands
- Darwin rebuild: `darwin-rebuild switch --flake .#MBP2025`
- Build Darwin flake: `darwin-rebuild build --flake .#MBP2025`

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
- `darwin/` - macOS configuration using nix-darwin
- `servo/` - NixOS configuration for a server
- `custom_iso.nix` - ISO builder configuration that embeds the servo configuration
- `build-iso.sh` - Quick ISO build script for x86_64
- `build-iso-monitor.sh` - ISO build script with progress monitoring and auto-copy
- Root directory contains shared configuration and build scripts

