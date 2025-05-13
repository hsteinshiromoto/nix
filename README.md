# Nix Flakes

## Build Nix ISO with

```bash
 nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./custom-iso.nix
```

## Darwin

`darwin/flake.nix`

Uptate Darwin with

```bash
darwin-rebuild switch --flake ~/.config/nix/darwin#MBP2025
```
