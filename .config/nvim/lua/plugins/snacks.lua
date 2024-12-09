return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		lazygit = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
	},
	keys = {
		{
			"<leader>n",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification History",
			mode = { "n" },
		},
		{
			"gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
			mode = { "n" },
		},
		{
			"gf",
			function()
				Snacks.lazygit.log_file()
			end,
			desc = "Lazygit Current File History",
			mode = { "n" },
		},
		{
			"gl",
			function()
				Snacks.lazygit.log()
			end,
			desc = "Lazygit Log (cwd)",
			mode = { "n" },
		},
		{
			"<leader>rf",
			function()
				Snacks.rename.rename_file()
			end,
			desc = "Rename File",
			mode = { "n" },
		},
	},
}
