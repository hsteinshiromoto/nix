# Nix Flakes

## Build Nix ISO with

```bash
 nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./custom_iso.nix
```

## Servidor

1. Create the symbolic links of the files in `servo/` folder to `/etc/nixos`.

2. Run the command from the folder `/etc/nixos/`
```bash
sudo nix flake update --flake . --impure
```

3. Rebuild with from the project root folder
```bash
sudo nixos-rebuild test --flake .#servidor
```

To swtich to a new build, replace the `test` with `switch`

## Darwin

`darwin/flake.nix`

Uptate Darwin with

```bash
darwin-rebuild switch --flake ~/.config/nix/darwin#MBP2025
```
