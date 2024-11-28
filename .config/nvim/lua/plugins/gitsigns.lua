local icons = require("config.icons")

return {
	"lewis6991/gitsigns.nvim",
	lazy = false,
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = icons.ui.BoldLineLeft .. "+" },
				change = { text = icons.ui.BoldLineLeft .. icons.ui.PlusMinus },
				delete = { text = icons.ui.BoldLineLeft .. "-" },
				topdelete = { text = icons.ui.BoldLineLeft .. icons.ui.ChevronUp },
				changedelete = { text = icons.ui.BoldLineLeft .. icons.ui.Delete },
				untracked = { text = "┆" },
			},
			signs_staged = {
				add = { text = icons.ui.BoldLineLeft .. "+" },
				change = { text = icons.ui.BoldLineLeft .. icons.ui.PlusMinus },
				delete = { text = icons.ui.BoldLineLeft .. "-" },
				topdelete = { text = icons.ui.BoldLineLeft .. icons.ui.ChevronUp },
				changedelete = { text = icons.ui.BoldLineLeft .. icons.ui.Delete },
				untracked = { text = "┆" },
			},
			-- Highlight also the line number
			numhl = true,
		})
	end,
}
