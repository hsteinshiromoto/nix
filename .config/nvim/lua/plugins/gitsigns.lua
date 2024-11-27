local icons = require("config.icons")

return {
	"lewis6991/gitsigns.nvim",
	lazy = false,
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "┃+" },
				change = { text = "┃" },
				delete = { text = "┃-" },
				topdelete = { text = "┃^" },
				changedelete = { text = "┃~" },
				untracked = { text = "┆" },
			},
			signs_staged = {
				add = { text = "┃+" },
				change = { text = "┃" },
				delete = { text = "┃-" },
				topdelete = { text = "┃^" },
				changedelete = { text = "┃~" },
				untracked = { text = "┆" },
			},
			-- Highlight also the line number
			numhl = true,
		})
	end,
}
