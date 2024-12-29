local icons = require("config.icons")

return {
	"lewis6991/gitsigns.nvim",
	lazy = false,
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "+" },
				change = { text = icons.ui.PlusMinus },
				delete = { text = "-" },
				topdelete = { text = icons.ui.ChevronUp },
				changedelete = { text = icons.ui.Cross },
				untracked = { text = "┆" },
			},
			signs_staged = {
				add = { text = "+" },
				change = { text = icons.ui.PlusMinus },
				delete = { text = "-" },
				topdelete = { text = icons.ui.ChevronUp },
				changedelete = { text = icons.ui.Cross },
				untracked = { text = "┆" },
			},
			-- Highlight also the line number
			numhl = true,
		})
	end,
}
