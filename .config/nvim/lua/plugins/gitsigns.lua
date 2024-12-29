local icons = require("config.icons")

return {
	"lewis6991/gitsigns.nvim",
	lazy = false,
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = icons.ui.ThickLeftLine .. "+" },
				change = { text = icons.ui.ThickLeftLine .. icons.ui.PlusMinus },
				delete = { text = icons.ui.ThickLeftLine .. "-" },
				topdelete = { text = icons.ui.ThickLeftLine .. icons.ui.ChevronUp },
				changedelete = { text = icons.ui.ThickLeftLine .. icons.ui.Cross },
				untracked = { text = "┆" },
			},
			signs_staged = {
				add = { text = icons.ui.ThickLeftLine .. "+" },
				change = { text = icons.ui.ThickLeftLine .. icons.ui.PlusMinus },
				delete = { text = icons.ui.ThickLeftLine .. "-" },
				topdelete = { text = icons.ui.ThickLeftLine .. icons.ui.ChevronUp },
				changedelete = { text = icons.ui.ThickLeftLine .. icons.ui.Cross },
				untracked = { text = "┆" },
			},
			-- Highlight also the line number
			numhl = true,
		})
	end,
}
