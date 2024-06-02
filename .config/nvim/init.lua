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
	{ "lewis6991/gitsigns.nvim" }
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

