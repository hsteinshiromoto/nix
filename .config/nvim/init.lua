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

local plugins = {
	{ "ellisonleao/gruvbox.nvim", priority = 1000 , config = true},
	{'nvim-telescope/telescope.nvim', tag = '0.1.6',
      		dependencies = { 'nvim-lua/plenary.nvim' }
    	},
	{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
	{ "sitiom/nvim-numbertoggle" },
	{ "lervag/vimtex",
  		--init = function()
    		-- VimTeX configuration goes here, e.g.
    		-- vim.g.vimtex_view_method = "zathura"
  		--end
	},
	{"NeogitOrg/neogit",
  		dependencies = {"nvim-lua/plenary.nvim",         -- required
    				"sindrets/diffview.nvim",        -- optional - Diff integration
    				-- Only one of these is needed, not both.
    				"nvim-telescope/telescope.nvim", -- optional
    				-- "ibhagwan/fzf-lua",              -- optional
  				},
  		config = true
	},
	{ "lewis6991/gitsigns.nvim" },
	{ "nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = { "nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    				}
	},
	{ 'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' }
	},
	{ "mbbill/undotree" },
	{ 'jiangmiao/auto-pairs' },
	{ "HiPhish/rainbow-delimiters.nvim" }
}
local opts = {}

require("lazy").setup(plugins, opts)

-- Setup Gruvbox
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

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
	ensure_installed = {"latex", "lua", "python", "toml", "vim", "vimdoc"},
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
		add 	= { text = '+' },
		delete 	= { text = '-' },
	},
	}
)

-- Setip Neotree
vim.keymap.set("n", "<C-t>", ":Neotree filesystem reveal left<CR>")

-- Setup Lualine
require('lualine').setup({
	options = { theme = 'gruvbox' },
})

-- Setup Undotree
vim.keymap.set('n', '<leader><F5>', vim.cmd.UndotreeToggle)
