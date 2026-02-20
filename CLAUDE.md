# CLAUDE.md

Use the `README.md` file as a context before start any change.

## Code Style Guidelines

- Use camelCase for variable/attribute names
- Group related configuration settings together
- Document complex configuration with comments
- Separate hardware-specific configuration
- Organize flakes with clear inputs and outputs structure
- Use descriptive hostnames, system identifiers, and variable names
- Place host-specific configurations in dedicated directories
- Reference official documentation in comments where possible
- For imports, place all imports at the top of files
- Prefer stable packages unless unstable is explicitly needed
- Only implement mouting of external drivers in first phase of the bootloarder when explicitely requested.

## Repository Structure

Refer to `README.md`.

## Instructions

1. Read the `Makefile` and use its targets to test and build the changes. Make sure to use the correct target depending on the host.

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

