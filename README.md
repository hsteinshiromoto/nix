# Nix Flakes

## Repository Structure

```
.
├── CLAUDE.md
├── custom_iso.nix              <- NixOS image configuration
├── darwin                      <- MacOS flake with Nix-Darwin
│   ├── flake.lock
│   └── flake.nix
├── flake.lock
├── flake.nix                   <- Main flake file
├── LICENSE
├── README.md
└── servo                       <- Server settings
    ├── configuration.nix
    ├── flake.lock
    └── flake.nix

```

## Build Nix ISO based on the flake settings

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
sudo nixos-rebuild test --flake .#servidor --impure
```

To switch to a new build, replace the `test` with `switch`.

## Darwin

`darwin/flake.nix`

Uptate Darwin with

```bash
darwin-rebuild switch --flake ~/.config/nix/darwin#MBP2025
```
