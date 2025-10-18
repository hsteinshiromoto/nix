# AGENTS.md

## Build Commands
- Update flake: `nix flake update`
- Rebuild NixOS: `sudo nixos-rebuild switch --flake .#servidor --impure`
- Rebuild Darwin: `sudo darwin-rebuild switch --flake .#MBP2025 --impure`
- Test config: `sudo nixos-rebuild test --flake .#servidor --impure`
- Build ISO: `nix build .#nixosConfigurations.custom_iso.config.system.build.isoImage`
- Validate config: `nix run github:nix-community/nixos-anywhere -- --flake .#servidor --vm-test`

## Code Style Guidelines
- Use camelCase for variable/attribute names
- Group related configuration settings together
- Place all imports at the top of files
- Document complex configurations with comments
- Reference official documentation for non-obvious settings
- Separate hardware-specific configuration into dedicated files
- Use descriptive hostnames and system identifiers
- Prefer stable packages unless unstable is explicitly needed
- Organize flakes with clear inputs/outputs structure
- Use 2-space indentation for Nix expressions