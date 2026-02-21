# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Starting after v3.1.0, releases use a calendar-week identifier with the format `YYYY-[W]WW`.

## [2026-W08] - 2026-02-20

### Features

#### VPN (ProtonVPN)
- Added ProtonVPN OpenVPN configuration for servo (`servo/vpn.nix`)
- Integrated SOPS for VPN credential management
- Moved OpenVPN settings from `configuration.nix` to dedicated `vpn.nix` module
- Added DNS resolve script (`update-resolv-conf.sh`) for VPN connectivity
- Added auto-start for VPN service
- Added openresolv for DNS resolution during VPN

#### Backup (BorgBackup)
- Added BorgBackup configuration for servo
- Configured automatic borg service startup
- Added backup instructions documentation
- Excluded jellyfin cache and transcodes from backup

#### Transmission Torrent Client
- Added Transmission torrent client to servo
- Configured Transmission with nginx reverse proxy
- Added RPC host whitelists for secure access

#### Nginx Reverse Proxy
- Added `servo/nginx.nix` for centralized reverse proxy configuration
- Configured Jellyfin with nginx reverse proxy
- Added nixos-jellyfin to replace `services.jellyfin` module
- Configured nginx for Home Assistant with self-signed SSL certificates

#### Home Assistant Enhancements
- Enabled Bluetooth support in Home Assistant
- Added Bluetooth settings to NixOS configuration
- Added Philips Hue integration with Home Assistant
- Removed nginx subpath routing (not supported); reverted to direct access on port 8123

#### Media Drive (mb.nix)
- Added `servo/mb.nix` for LUKS-encrypted drive mounting at `/mnt/mb`
- Configured Samba share exposure from mbp2023 to mb
- Replaced auto-decrypt/mount with manual justfile targets (decrypt_disk, mount_disk, unmount_disk)

#### AWS Configuration
- Added `common/aws.nix` for SOPS-managed AWS configuration using dendritic pattern
- Simplified AWS config to write directly to `~/.aws` with sops-nix workaround

#### Claude Code Integration
- Added `common/claude.nix` for Claude Code settings with SOPS secrets
- Applied dendritic pattern: parameterized hostname for host-specific bedrock secret paths
- Upgraded claude settings to use Opus 4.6

#### Encrypted Journal
- Added git-crypt encryption for journal files (GPG key `CA81F56B4A7B6269`)
- Added git-crypt usage instructions to README
- Added git-crypt collaborator

#### Build & Makefile Improvements
- Simplified Makefile targets
- Renamed darwinConfigurations hostnames to lowercase
- Added `test_darwin` target in Makefile
- Improved Makefile documentation
- Added build packages (gnumake, gcc, pkg-config) to `servo/custom_iso.nix`
- Set default command to build test without switching

### Bug Fixes

- Fixed nixos-upgrade DNS failure during VPN startup
- Fixed Tailscale/ProtonVPN conflict with `checkReversePath = "loose"`, `trustedInterfaces`, and service ordering
- Fixed jellyfin permissions: added symlinks to libraries and media group
- Fixed `runSopsNix` activation script error
- Fixed sops-nix PATH and GPG workaround for macOS
- Fixed sops-nix `AWS_BEARER_TOKEN_BEDROCK` secret decryption
- Fixed homebrew tap issue
- Fixed darwin launch service issue
- Fixed password/username format issues in VPN credentials
- Moved from masapps to homebrew casks to resolve installation issues
- Renamed ollama to ollama-app

### Configuration Changes

#### SOPS Updates
- Updated `servo/sops.nix` as mb SOPS is no longer available
- Changed bedrock secrets location
- Added default id value for SOPS configuration

#### NixOS (servo)
- Enabled nix-ld
- Added authkey to Tailscale
- Configured firewall for Tailscale/VPN coexistence
- Added `just` to `servo/home.nix` for manual drive management

#### Nix-Darwin (mbp2023, mbp2025)
- Imported `claude.nix` into mbp2023
- Added linearmouse cask to mb configuration

### Package Additions

#### mbp2025
- witr, portkiller (brew packages)
- taws (via custom tap)
- cargo
- opencode CLI
- git-crypt
- Signal
- sqlite
- jnv

#### mbp2023
- hledger
- Signal
- lua, lua-language-server

#### servo
- proton-pass-cli
- openresolv

### Dependencies

- Updated `flake.lock` (multiple updates throughout the release)

### Removals

- Removed Windows app
- Removed automatic decrypt/mount of `/mnt/mb` (replaced with manual justfile targets)
- Removed redundant packages and unused code

### Documentation

- Updated `CLAUDE.md` with deploy command and improved instructions
- Updated `README.md` with git-crypt usage, encrypted journal section
- Added backup instructions for servo
- Improved Makefile documentation
- Added sanity_check and deploy commands to Claude skills

### Statistics

- **Files Changed**: 45 files with 1,009 insertions and 249 deletions
- **Date Range**: 2026-01-07 to 2026-02-20

---

## [3.1.0] - 2026-01-07

### Features

#### TPM2 Support
- Added TPM2 (Trusted Platform Module) support for secure boot
- Configured TPM2 enrollment for LUKS disk encryption
- Added `nixos_tpm` Makefile target for TPM enrollment
- Added documentation for TPM2 key creation and troubleshooting

#### Media Server (Jellyfin)
- Added Jellyfin media server configuration (`servo/jellyfin.nix`)
- Configured hardware acceleration with VDPAU driver
- Added ffmpeg-headless to mbp2023 for video processing

#### Media Drive Management
- Added encrypted media drive support (`servo/media.nix`)
- Configured auto-unlock and auto-mount at boot using systemd
- Added condition to unlock only after udev has finished
- Added encrypted documentation (`servo/media.md.gpg`) for setup instructions

#### Network Manager Improvements
- Renamed `wifi.nix` to `network_manager.nix` for better clarity
- Added support for main and alternative network connections
- Integrated network manager into custom ISO configuration

#### Git Server Enhancements
- Configured disko partition for git server storage
- Fixed git partition space allocation issues
- Added network manager support to custom ISO

### Bug Fixes

- Fixed media drive automount issue
- Fixed missing TPM configuration in configuration.nix
- Fixed VDPAU driver bug for hardware video acceleration
- Fixed Syncthing missing `dataDir` configuration
- Fixed `age_derived_key` location in SOPS configuration
- Fixed Time Machine UUID configuration

### Configuration Changes

#### SOPS Updates
- Added SOPS dependencies in `servo/sops.nix`
- Moved SSH authorized keys SOPS dependency to sops.nix
- Updated dependencies for gitconfig.yaml from SOPS repository
- Updated SOPS file dependencies due to repository restructure

#### NixOS (servo)
- Updated NixOS version in configuration.nix
- Propagated network manager changes to configuration.nix
- Consolidated SOPS configuration in dedicated module

#### Build & Deployment
- Added `get_iso` Makefile target to retrieve ISO via rsync/scp
- Added `FLAGS` argument to partition target
- Changed ISO transfer method from scp to rsync for better performance
- Added `nixos_tpm` target for TPM enrollment

### Dependencies

- Updated flake.lock (multiple updates throughout the release)
- Merged tag '25.11' into dev branch

### Removals

- Removed `servo/wifi.nix` (renamed to `network_manager.nix`)

### Statistics

- **Files Changed**: 17 files with 339 insertions and 143 deletions
- **Date Range**: 2025-11-01 to 2026-01-07

---

## [3.0.0] - 2025-10-24

### Major Changes

#### Configuration Refactoring
- **Common Configuration Modules**: Introduced shared configuration modules in `common/` directory for better code reuse across systems
  - `common/gitconfig.nix`: Centralized Git configuration with SOPS integration for secure credential management
  - `common/gitlab.nix`: GitLab CLI configuration with token management via SOPS
  - `common/nu.nix`: Nushell configuration shared across all systems
  - `common/nvim.nix`: Neovim configuration module
  - `common/sops.nix`: SOPS secrets management configuration

#### Home Manager Migration
- Migrated package management from system-level to home-manager for better user-level control
- **Fixed Critical Bug**: Resolved home-manager packages not installing on nix-darwin by setting `home-manager.useUserPackages = false`
- Migrated the following packages to home-manager:
  - Shell tools: nushell, starship, atuin, bat, eza, zoxide, yazi
  - Development tools: awscli, ruff, uv, pass
  - Git tooling: delta, git-flow
  - AI/CLI tools: claude-code, gemini-cli, opencode

### Features

#### Secrets Management
- Integrated SOPS (Secrets OPerationS) for secure secret management across all systems
- Added GPG-based decryption support for SOPS
- Configured secure handling of:
  - Git credentials (email, signing keys)
  - GitLab tokens
  - SSH keys and credentials

#### Shell Improvements
- **Nushell Integration**: Full nushell support with declarative configuration
  - Custom config.nu and env.nu management
  - Vi mode editing
  - Starship and atuin integration
  - Custom aliases (ls, cat → bat, cd → zoxide)
  - AWS identity helper aliases
- Improved shell integration for starship, atuin, and bat

#### Development Tools
- Added GitLab CLI (glab) with token management
- Added JIRA CLI for issue tracking
- Enhanced Python development environment:
  - Ruff linter/formatter with custom settings
  - UV package manager with prebuilt environment variable
  - Task tags support in ruff
- Added nixd LSP for Nix language support
- Integrated delta for improved git diffs

#### Security & Authentication
- Comprehensive YubiKey support:
  - GPG agent configuration for YubiKey
  - YubiKey Manager packages
  - PCSCD service enablement
  - Yubikey-authenticator application
- Password management:
  - Pass (password-store) with pass-otp extension
  - Proton Pass application
  - GPG Suite integration (macOS)
- Added git-crypt for repository encryption

### Package Additions

#### AI & Productivity
- claude-code: Claude AI CLI assistant
- gemini-cli: Google Gemini CLI
- opencode: Code opening utility
- calcure: Terminal calendar application
- cursor-cli: Cursor editor CLI

#### Development Tools
- dbeaver: Database management tool
- texliveFull: Complete LaTeX distribution
- taproom: Homebrew tap manager
- codex: Code indexing tool

#### System Utilities
- oversight: macOS security monitoring
- syncthing: File synchronization (with user configuration)
- gocryptfs with macfuse: Encrypted filesystem support
- usbutils: USB device utilities
- qrencode: QR code generator
- karabiner-elements: Keyboard customization (macOS)

#### File Management & Navigation
- yazi: Terminal file manager (migrated to home-manager)
- eza: Modern ls replacement (migrated to home-manager)
- zoxide: Smarter cd command (migrated to home-manager)

### Configuration Changes

#### Build & Deployment
- Updated Makefile targets for darwin_2023 and darwin_2025
- Added `--impure` flag support for SOPS integration
- Improved build process documentation

#### NixOS (servo)
- Enhanced hardware configuration
- Added WiFi configuration module (`servo/wifi.nix`)
- Added YubiKey configuration module (`servo/yubikey.nix`)
- User group management improvements

#### Nix-Darwin (mbp2023, mbp2025)
- Garbage collection configured to keep only 5 builds
- Home-manager integration fixes
- Improved XDG_CONFIG_HOME handling
- Homebrew integration improvements

### Bug Fixes

- Fixed username definition warning in gitconfig.nix
- Resolved home-manager package installation issues on nix-darwin
- Fixed double declaration of atuin
- Resolved nushell config file conflicts with env.nu
- Fixed syntax errors in home.nix configurations
- Corrected ruff settings integration
- Resolved SOPS gitlab token loading issues
- Fixed nushell edit mode configuration
- Corrected pass-otp extension integration
- Fixed pinentry package configuration
- Resolved maccy clipboard manager issues
- Fixed missing homebrew tap errors

### Documentation

- **New Documentation Files**:
  - `AGENTS.md`: Guidelines for AI agent usage
  - `CLAUDE.md`: Enhanced with troubleshooting section for home-manager issues
  - `files.md`: File structure and organization documentation
- Updated README.md with current system information
- Improved inline comments throughout configuration files
- Added troubleshooting guide for common issues

### Removals

- Removed deprecated packages:
  - logioptionsplus (reverted)
  - utm
  - doppler cli (reverted)
  - bibiman
  - nushell highlight plugin
  - Redundant package declarations
- Cleaned up duplicate configurations
- Removed individual sops.nix files in favor of common/sops.nix

### Dependencies

- Updated flake.lock multiple times throughout the release cycle
- Upgraded to NixOS 25.05 (minimal ISO: nixos-minimal-25.05.804570.c7ab75210cb8)
- Updated nix-darwin dependencies
- Updated home-manager dependencies

### Breaking Changes

⚠️ **Important**: This release includes significant configuration restructuring:

1. **Home Manager Migration**: Packages previously installed at system level are now user-level
   - Users may need to update their PATH or shell configurations
   - Some packages may need to be explicitly added to home.nix

2. **SOPS Integration**: Secret management now requires SOPS configuration
   - GPG keys must be properly configured
   - Existing plain-text secrets need migration to SOPS

3. **Common Modules**: Configuration files moved to common/ directory
   - Custom configurations may need to import from new locations
   - System-specific overrides may be required

4. **Nushell as Primary Shell**: Systems now default to nushell
   - Bash scripts and aliases need nushell equivalents
   - Shell startup files (rc, profile) may need updates

### Migration Guide

#### For Existing Users

1. **Update Git Configuration**:
   ```bash
   # Ensure your GPG keys are properly configured for SOPS
   gpg --list-keys
   ```

2. **Home Manager Packages**:
   - Run `darwin-rebuild switch --flake .#<hostname>` from repository root
   - Verify packages in `~/.local/state/nix/profiles/profile/bin/`

3. **Shell Configuration**:
   - Nushell config files are now managed declaratively
   - Custom configurations should be added to appropriate .nix files

4. **Secrets Management**:
   - Set up SOPS encryption keys
   - Migrate existing secrets to SOPS-encrypted format

### Statistics

- **Total Commits**: 221
- **Files Changed**: 24 files with 1,093 insertions and 410 deletions
- **Contributors**: Humberto STEIN SHIROMOTO
- **Date Range**: 2025-08-06 to 2025-10-24

---

## [2.2.0] and earlier

See git history for changes prior to v3.0.0.

[2026-W08]: https://github.com/hsteinshiromoto/nix/compare/2026-W02...release/2026-W08
[3.1.0]: https://github.com/hsteinshiromoto/nix/compare/v3.0.0...release/2026-W02
[3.0.0]: https://github.com/hsteinshiromoto/nix/compare/main...release/v3.0.0
