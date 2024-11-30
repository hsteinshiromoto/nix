local icons = require("config.icons")

return {
	{
		"kevinhwang91/nvim-ufo",
		lazy = false,
		ft_ignore = { "neo-tree", "alpha", "Outline" },
		dependencies = {
			"kevinhwang91/promise-async",
			"neovim/nvim-lspconfig",
			{
				"luukvbaal/statuscol.nvim",
				lazy = false,
				config = function()
					vim.opt.number = true
					-- vim.opt.relativenumber = true
					local builtin = require("statuscol.builtin")

					require("statuscol").setup({
						relculright = true,
						segments = {
							{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },
							{ text = { "%s" }, colwidth = 1, maxwidth = 1, auto = false, click = "v:lua.ScSa" }, -- git signs
							{ text = { "%=", "%l " }, click = "v:lua.ScLa" }, -- Absolute line numbers

							-- { text = { "%r " }, click = "v:lua.ScLa" }, -- Relative line numbers
							-- FIX: Bugs with the following code block. Need to add Diagnostic.
							-- {
							-- 	sign = {
							-- 		namespace= { "Diagnostic" },
							-- 		maxwidth = 2,
							-- 		auto = true,
							-- 	},
							-- 	click = "v:lua.ScSa",
							-- },
						},
					})
				end,
			},
			{
				"lewis6991/gitsigns.nvim",
				lazy = false,
				config = function()
					require("gitsigns").setup({
						signs = {
							add = { text = icons.ui.BoldLineLeft .. "+" },
							change = { text = icons.ui.BoldLineLeft .. icons.ui.PlusMinus },
							delete = { text = icons.ui.BoldLineLeft .. "-" },
							topdelete = { text = icons.ui.BoldLineLeft .. icons.ui.ChevronUp },
							changedelete = { text = icons.ui.BoldLineLeft .. icons.ui.Cross },
							untracked = { text = "┆" },
						},
						signs_staged = {
							add = { text = icons.ui.BoldLineLeft .. "+" },
							change = { text = icons.ui.BoldLineLeft .. icons.ui.PlusMinus },
							delete = { text = icons.ui.BoldLineLeft .. "-" },
							topdelete = { text = icons.ui.BoldLineLeft .. icons.ui.ChevronUp },
							changedelete = { text = icons.ui.BoldLineLeft .. icons.ui.Cross },
							untracked = { text = "┆" },
						},
						-- Highlight also the line number
						numhl = true,
					})
				end,
			},
		},
		event = "BufReadPost",
		init = function()
			vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
			vim.o.foldcolumn = "1" -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
		end,
		opts = {
			provider_selector = function()
				return { "treesitter", "indent" }
			end,
		},
	},
	{ "anuvyklack/fold-preview.nvim", dependencies = "anuvyklack/keymap-amend.nvim", config = true, lazy = false },
}
