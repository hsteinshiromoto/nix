local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- Install Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})

-- Setup Treesitter
-- In Linux, TreeSitter requires rust and tree-sitter-cli to be installed [1]. To do this:
-- 	1. Install Rust using the instructions from [2].
-- 	2. Configure cargo to be used with zsh with the command `. "$HOME/.cargo/env"`. Please note the leading dot in this command.
-- 	3. Install treesitter-cli with the command `cargo install tree-sitter-cli`
-- References:
-- 	[1] https://github.com/nvim-treesitter/nvim-treesitter/issues/1097#issuecomment-1368177624
-- 	[2] https://www.rust-lang.org/tools/install
local config = require("nvim-treesitter.configs")
config.setup({
	ensure_installed = {"dockerfile", "latex", "lua", "make", "python", "toml", "vim", "vimdoc"},
	auto_install = true,
	highlight = {enable = true },
	indent = { enable = true}
	})

-- Setup relative and absolute numbers
-- References:
--	[1] https://www.reddit.com/r/neovim/comments/14xxw1p/display_both_relative_and_absolute_line_numbers/

vim.opt.nu = true
vim.opt.relativenumber = true
vim.o.statuscolumn = "%s %l %r "

-- Setup Gitgitsigns
require('gitsigns').setup({
	signs = {
		add 	= { text = 'M+' },
		change	= { text = 'M' },
		delete 	= { text = 'M-' },
		topdelete = { text = '^' },
    		changedelete = { text = '|<' },
	},
	}
)

-- Setup Neotree
vim.keymap.set("n", "<C-k>", ":Neotree filesystem toggle left<CR>")
use_libuv_file_watcher=true
-- Setup Lualine
require('lualine').setup({
	options = { theme = 'gruvbox' },
})

-- Setup Undotree
vim.keymap.set('n', '<C-u>', vim.cmd.UndotreeToggle)

-- Setup Neogit
vim.keymap.set('n', '<C-g>', ":Neogit<CR>")

-- Setup Tab Commands
vim.keymap.set('n', '<C-t>', ":tabnew<CR>")

