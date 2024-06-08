return {
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
	{ "HiPhish/rainbow-delimiters.nvim" },
	{ "tpope/vim-commentary" },
	{'romgrk/barbar.nvim',
		dependencies = {
			'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
			'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
		},
		init = function() vim.g.barbar_auto_setup = false end,
		opts = {-- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
			-- animation = true,
			-- insert_at_start = true,
			},
    		version = '^1.0.0', -- optional: only update when a new 1.x version is released
  	},
	{ 'alexghergh/nvim-tmux-navigation', config = function()
		
		local nvim_tmux_nav = require('nvim-tmux-navigation')
		nvim_tmux_nav.setup {
			disable_when_zoomed = true -- defaults to false
		}

		vim.keymap.set('n', "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
		vim.keymap.set('n', "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
		vim.keymap.set('n', "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
		vim.keymap.set('n', "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
		vim.keymap.set('n', "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)

		end
	}
}

