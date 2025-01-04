return {
	"renerocksai/telekasten.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-telescope/telescope.nvim", "nvim-telekasten/calendar-vim" },
	-- Launch panel if nothing is typed after <leader>z
	vim.keymap.set("n", "<leader>zp", "<cmd>Telekasten panel<CR>"),

	-- Most used functions
	vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>"),
	vim.keymap.set("n", "<leader>zg", "<cmd>Telekasten search_notes<CR>"),
	vim.keymap.set("n", "<leader>zd", "<cmd>Telekasten goto_today<CR>"),
	vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>"),
	vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>"),
	vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten show_calendar<CR>"),
	vim.keymap.set("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>"),
	vim.keymap.set("n", "<leader>zI", "<cmd>Telekasten insert_img_link<CR>"),

	-- Call insert link automatically when we start typing a link
	-- vim.keymap.set("i", "[[", "<cmd>Telekasten insert_link<CR>"),
	config = function()
		require("telekasten").setup({
			calendar_opts = {
				calendar_monday = 0,
				weeknm = 1,
			},
			home = vim.fn.expand("~/Personal/"),
			vaults = {
				zettelkasten = { home = vim.fn.expand("~/zettelkasten") },
				lor = { home = vim.fn.expand("~/Work/lor") },
				personal = { home = vim.fn.expand("~/Personal") },
			},
		})
	end,
}
