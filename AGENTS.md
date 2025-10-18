# AGENTS.md

## Build Commands
- Update flake: `make update`
- Rebuild NixOS: `make nixos_rebuilt FLAGS="switch"`
- Rebuild Darwin: `make darwin_X`, where X is either 22, 23 or 25.
- Test config: `sudo nixos-rebuild test --flake .#servidor --impure`
- Build ISO: `nixos_iso`
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
