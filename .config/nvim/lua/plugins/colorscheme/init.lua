return {
	{
		"folke/styler.nvim",
		event = "VeryLazy",
		config = function()
			require("styler").setup({
				themes = {
					markdown = { colorscheme = "gruvbox" },
				},
			})
		end,
	},
	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
		-- require("catppuccin").setup({
		-- 	integrations = {
		-- 		aerial = true,
		-- 		blink_cmp = true,
		-- 		cmp = true,
		-- 		dap = true,
		-- 		dap_ui = true,
		-- 		diffview = true,
		-- 		flash = true,
		-- 		gitgraph = true,
		-- 		gitsigns = true,
		-- 		indent_blankline = {
		-- 			enabled = true,
		-- 			scope_color = "lavender", -- catppuccin color (eg. `lavender`) Default: text
		-- 			colored_indent_levels = false,
		-- 		},
		-- 		lsp_trouble = true,
		-- 		markdown = true,
		-- 		mason = true,
		-- 		mini = {
		-- 			enabled = true,
		-- 			indentscope_color = "",
		-- 		},
		-- 		neotest = true,
		-- 		noice = true,
		-- 		notifier = true,
		-- 		notify = true,
		-- 		nvim_surround = true,
		-- 		nvimtree = true,
		-- 		render_markdown = true,
		-- 		snacks = {
		-- 			enabled = true,
		-- 			-- indent_scope_color = "catppuccin-mocha", -- catppuccin color (eg. `lavender`) Default: text
		-- 		},
		-- 		telekasten = true,
		-- 		treesitter = true,
		-- 		treesitter_context = true,
		-- 		which_key = true,
		-- 		ufo = true,
		-- 	},
		-- }),
	},
	-- {
	-- 	"ellisonleao/gruvbox.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("gruvbox").setup()
	-- 		vim.o.background = "dark" -- or "light" for light mode
	-- 		vim.cmd([[colorscheme gruvbox]])
	-- 	end,
	-- },
}
