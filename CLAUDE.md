# CLAUDE.md - Guidelines for the dotfiles.linux Repository

## Commands
- `make help` - List all available make commands
- `make packages` - Install OS packages (ansible-playbook with --ask-become-pass)
- `make dotfiles` - Setup dotfiles (runs after packages)
- `make nvim` - Build NeoVim Docker image
- `make build` - Build Docker image
- `make run` - Run Docker container
- `make changelog` - Update CHANGELOG.md using git-cliff
- `make tree` - Print directory tree structure
- `make clean` - Remove log files

## Code Style Guidelines
- **Python**: 4-space indent, snake_case variables/functions, docstrings, PEP 8
- **Shell/Bash**: 4-space indent, lowercase_with_underscore variables
- **YAML**: 2-space indent, list items with single dash and space
- **General**: Organize imports (stdlib first), specific error handling, 80-90 chars per line
- **Comments**: Clear, concise descriptions starting with # and a space
- **Git commits**: Descriptive, feature/fix prefixed messages

## Repository Structure
This repo contains dotfiles, configurations, and setup scripts organized by platform (macos/linux) and tools/applications.