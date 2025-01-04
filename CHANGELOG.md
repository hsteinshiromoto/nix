# Changelog

## v2.5.0

See link: https://github.com/hsteinshiromoto/dotfiles.linux/pull/3#issuecomment-2570734306


## v2.1.0

## Added

Plugin Integrations:
- Added nvim-ufo for enhanced folding capabilities with dependencies on `promise-async` and `nvim-lspconfig`.
- Integrated `statuscol.nvim` for customizable status columns.
- Added `gitsigns.nvim` for Git integration with custom signs and line number highlighting.
- Included `fold-preview.nvim` for fold preview functionality.
- Added `todo-comments.nvim` for managing and navigating TODO comments.
- Integrated `lazygit.nvim` for Git management within Neovim.
- Added `tabout.nvim` for enhanced tab navigation.
- Integrated `neogen` for code documentation generation.
- Added `knap` for previewing markdown and LaTeX documents.

## Changed

Configuration Enhancements:
- Updated `statuscol.nvim` configuration to include segments for fold functions, git signs, and absolute line numbers.
- Modified `gitsigns.nvima configuration to include custom icons and enable line number highlighting.
- Updated `nvim-ufo` settings for fold column and level management.
- Enhanced `lualine.nvim` setup with custom components and icons.

## Fixed

Bug Fixes:
- Addressed issues with `statuscol.nvim` related to diagnostic signs.
- Resolved flickering issue with `lualine.nvim` when using components.git_repo.

## Removed

Deprecated Plugins:
- Commented out the use of `line-number-change-mode.nvim` due to error messages and color unpredictability.

## Notes

Documentation:
- Added references and comments for better understanding and future improvements.
- Included TODOs for potential enhancements and investigations.
