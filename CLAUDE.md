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
- `mbp2023/` - macOS configuration using nix-darwin
- `servo/` - NixOS configuration for a server
- Root directory contains shared configuration like custom ISO settings

## Troubleshooting

### Home-manager packages not installing on nix-darwin

**Issue:** Packages defined in `home.packages` within home.nix are not being installed when running `darwin-rebuild switch`. Home-manager activates but doesn't create new generations with the packages.

**Symptoms:**
- `darwin-rebuild switch` shows "Activating home-manager configuration"
- `which <package>` returns "not found"
- Package not found in `~/.local/state/nix/profiles/profile/bin/`
- Home-manager profile generation date is old and hasn't updated

**Root Cause:** Setting `home-manager.useUserPackages = true` in nix-darwin configuration can prevent home-manager from managing its own profile correctly. This setting attempts to integrate home-manager packages into the nix-darwin user packages, but may not work as expected.

**Solution:** Set `home-manager.useUserPackages = false` in the nix-darwin flake configuration:

```nix
home-manager.darwinModules.home-manager {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = false;  # Changed from true to false
  home-manager.users.<username> = ./home.nix;
}
```

**Debugging Steps:**
1. Check if package is in home-manager profile: `ls ~/.local/state/nix/profiles/profile/bin/ | grep <package>`
2. Check current home-manager generation: `readlink ~/.local/state/nix/profiles/profile`
3. Check generation timestamps: `/bin/ls -lt ~/.local/state/nix/profiles/`
4. Verify package exists in nixpkgs: `nix search nixpkgs <package>`
5. Test package installation: `nix build --no-link --print-out-paths nixpkgs#<package>`
6. Check home-manager configuration is loaded: Review darwin-rebuild output for "Activating home-manager configuration"
7. Run darwin-rebuild from repository root (not subdirectory): `sudo darwin-rebuild switch --flake .#<hostname> --impure`

