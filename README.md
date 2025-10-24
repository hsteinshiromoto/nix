![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/hsteinshiromoto/nix?style=flat)
![LICENSE](https://img.shields.io/badge/license-MIT-lightgrey.svg)
# Nix Flakes Repository

## Repository Structure

```
.
├── bin/                        # Build and installation scripts
│   ├── docker-nix.conf
│   ├── install.sh
│   └── make_iso.sh
├── common/                     # Shared configuration modules (v3.0+)
│   ├── gitconfig.nix          # Git configuration with SOPS integration
│   ├── gitlab.nix             # GitLab CLI configuration
│   ├── nu.nix                 # Nushell configuration
│   ├── nvim.nix               # Neovim configuration
│   └── sops.nix               # SOPS secrets management
├── mba2022/                    # MacBook Air 2022 configuration
│   └── flake.nix
├── mbp2023/                    # MacBook Pro 2023 configuration
│   ├── flake.nix
│   └── home.nix               # Home-manager configuration
├── mbp2025/                    # MacBook Pro 2025 configuration
│   ├── flake.nix
│   └── home.nix               # Home-manager configuration
├── servo/                      # NixOS server configuration
│   ├── configuration.nix
│   ├── custom_iso.nix         # Custom ISO build configuration
│   ├── disko-config.nix       # Disk partitioning configuration
│   ├── flake.lock
│   ├── flake.nix
│   ├── hardware-configuration.nix
│   ├── home.nix               # Home-manager configuration
│   ├── README.md
│   ├── wifi.nix               # WiFi configuration
│   └── yubikey.nix            # YubiKey configuration
├── AGENTS.md                   # AI agent usage guidelines
├── CHANGELOG.md                # Version history and changes
├── CLAUDE.md                   # Claude Code instructions and troubleshooting
├── files.md                    # File structure documentation
├── flake.lock                  # Root flake lock file
├── flake.nix                   # Root flake configuration
├── LICENSE
├── Makefile                    # Build automation commands
├── nix.conf                    # Nix configuration
├── README.md                   # This file
└── .tmuxinator.yml            # Tmuxinator project configuration

```

### Key Directories

- **common/**: Shared configuration modules introduced in v3.0.0 for code reuse across systems
- **mbp2023/, mbp2025/, mba2022/**: macOS configurations using nix-darwin with home-manager
- **servo/**: NixOS server configuration with custom ISO, disk partitioning, and hardware-specific settings

## Instructions

### 1. Clone this repository in your `XDG_CONFIG_HOME` or `~/.config/nix`:
```bash
git clone https://github.com/hsteinshiromoto/nix ~/.config/nix
```

### 2. Install NixOS or Nix package manager

#### NixOS

1. Clone this repository using the command
```bash
git clone https://github.com/hsteinshiromoto/nix ~/.config/nix
```

2. Navigate to the `~/.config/nix` folder and partition the disk with the command:
```bash
make partition
```
After finishing this command, a password will be request to encrypt the disk.

3. Once done, install NixOS with the command
```bash
make nixos_install
```
and reboot.

4. After reboot login, and run `nmtui` to setup the connections again.

5. Clone this repository again, as per step 1.

6. Run the command
```bash
sudo ln -s /home/hsteinshiromoto/.config/nix/servo/configuration.nix /etc/nixos/
```
to create a symbolic link to the `configuration.nix` file of this repository.

For more details, follow the instructions in this [README.md](servo/README.md).

##### Using Nixos Anywhere

1. Make sure to setup passwordless sudo with the command
```bash
ssh -t hsteinshiromoto@<ip> "sudo chmod 440 /etc/sudoers.d/nixos-anywhere && sudo grep -E '^\s*#includedir\s+/etc/sudoers.d' /etc/sudoers || echo '@includedir /etc/sudoers.d' | sudo tee -a /etc/sudoers"

```
2. Run the command
```bash
nix run github:nix-community/nixos-anywhere -- --flake $(pwd)#servidor --target-host hsteinshiromoto@<ip>
```

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
