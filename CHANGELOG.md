# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

#### Nix-Darwin (MBP2023, MBP2025)
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

[3.0.0]: https://github.com/hsteinshiromoto/nix/compare/main...release/v3.0.0
