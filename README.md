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
make nixos_rebuild FLAGS=test
```
To switch to a new build, replace the `test` with `switch`.

#### Darwin

Use `Makefile` commands of run in terminal
```bash
make nixos_rebuild FLAGS=switch
```

## Neovim Remote Server

The NixOS server (`servo`) runs a headless Neovim server that allows remote UI connections.

### Server Setup

The Neovim server is configured as a systemd service in `servo/configuration.nix`:

- **Service name**: `nvimd.service`
- **Listen address**: `0.0.0.0:9000`
- **Auto-start**: Enabled on boot via `multi-user.target`

**Key configuration details:**
- Port 9000 is opened in the firewall
- Service runs as user `hsteinshiromoto`
- PATH includes git and tree-sitter for plugin compatibility
- Working directory: `/home/hsteinshiromoto/`

### Client Connection

Due to Neovim RPC protocol limitations over direct network connections, an SSH tunnel is required.

#### Using the Helper Script (Recommended)

```bash
# Connect with default settings (servidor:9000)
# Uses Tailscale hostname resolution
bash bin/nvim-remote.sh
```

```bash
# Connect using Tailscale hostname
bash nvim-remote.sh servidor
```

```bash
# Connect using IP address
bash bin/nvim-remote.sh <SERVER_NAME_OR_IP>
```

```bash
# Connect to custom server/port
bash bin/nvim-remote.sh <SERVER_NAME_OR_IP> <PORT>
```

The script automatically:
1. Resolves Tailscale hostnames to IP addresses (if applicable)
2. Creates an SSH tunnel to the server
3. Connects Neovim client via the tunnel
4. Cleans up the tunnel when you exit Neovim

**Note:** The script supports both Tailscale hostnames (e.g., `servidor`) and IP addresses. If Tailscale is installed, it will automatically resolve hostnames.

#### Manual Connection

If you prefer manual control:

```bash
# 1. Start SSH tunnel (runs in background)
ssh -L 9000:127.0.0.1:9000 <SERVER_NAME_OR_IP> -N -f
```

```bash
# 2. Connect to Neovim via the tunnel
nvim --server 127.0.0.1:9000 --remote-ui
```

```bash
# 3. Kill the tunnel when done
pkill -f "ssh -L 9000:127.0.0.1:9000"
```

### Server Management

**Check service status:**
```bash
sudo systemctl status nvimd
```

**Restart service:**
```bash
sudo systemctl restart nvimd
```

**View logs:**
```bash
sudo journalctl -u nvimd -n 50 --no-pager
```

**Check if listening:**
```bash
sudo ss -tlnp | grep 9000
```

### Troubleshooting

**Connection refused error:**
- Ensure the service is running: `sudo systemctl status nvimd`
- Verify port is listening: `sudo ss -tlnp | grep 9000`
- Check SSH tunnel is active: `pgrep -f "ssh -L 9000"`
- Test local connection on server: `nvim --server 127.0.0.1:9000 --remote-send ':echo "test"<CR>'`

**Plugin errors in logs:**
- The service runs with `-u NONE` to avoid config issues
- To use custom config, create a minimal server-specific init.lua

**Segmentation fault:**
- This occurs when trying to use `--remote-ui` over direct TCP (without SSH tunnel)
- Always use SSH tunneling for remote UI connections
