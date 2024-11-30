local icons = require("config.icons")

return {
	"kevinhwang91/nvim-ufo",
	lazy = false,
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
}
