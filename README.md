# Nix Flakes

## Repository Structure

```
.
├── bin
│   ├── docker-nix.conf
│   ├── install.sh
│   └── make_iso.sh
├── CLAUDE.md
├── custom_iso.nix
├── flake.lock
├── flake.nix
├── LICENSE
├── Makefile
├── mba2022
│   └── flake.nix
├── mbp2023
│   ├── flake.lock
│   └── flake.nix
├── mbp2025
│   ├── flake.lock
│   └── flake.nix
├── nix.conf
├── README.md
└── servo
    ├── configuration.nix
    ├── disko-config.nix
    ├── flake.lock
    ├── flake.nix
    └── hardware-configuration.nix

```
## Instructions

### 1. Clone this repository in your `XDG_CONFIG_HOME` or `~/.config/nix`:
```bash
git clone https://github.com/hsteinshiromoto/nix ~/.config/nix
```

### 2. Install NixOS or Nix package manager

#### NixOS

Follow the instructions in this [README.md](<README#Server Instructions.>).

#### Nix Package Manager

Follow the instructions from the website [Nix](https://nixos.org/download/).

##### Nix-Darwin

Install [nix-darwin](https://github.com/nix-darwin/nix-darwin) by running the command

```bash
sudo nix run nix-darwin -- switch --flake .#MBX202Y
```
in the project root of this repository, where `X` is either `A` or `P`, and `Y` is either 2, 3, or 5.


### 3. Rebuilding a flake version

#### NixOS

Use `Makefile` commands or run in terminal

```bash
sudo nixos-rebuild test --flake .#servidor --impure
```
To switch to a new build, replace the `test` with `switch`.

#### Darwin

Use `Makefile` commands of run in terminal
```bash
sudo darwin-rebuild switch --flake .#MBP2025
```
