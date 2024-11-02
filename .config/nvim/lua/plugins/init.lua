return {
	"nvim-lua/plenary.nvim",
	"MunifTanjim/nui.nvim",
	{
		"nvim-tree/nvim-web-devicons",
		config = { default = true },
	},
	{ "nacro90/numb.nvim", event = "BufReadPre", config = true },
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		config = true,
	},
	{
		"sitiom/nvim-numbertoggle"
	},
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		enabled = true,
		config = { default = true }, -- same as config = true
	},
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		config = true,
	},
	{
		"monaqa/dial.nvim",
		event = "BufReadPre",
		config = function()
			vim.api.nvim_set_keymap("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
			vim.api.nvim_set_keymap("n", "<C-x>", require("dial.map").dec_normal(), { noremap = true })
			vim.api.nvim_set_keymap("v", "<C-a>", require("dial.map").inc_visual(), { noremap = true })
			vim.api.nvim_set_keymap("v", "<C-x>", require("dial.map").dec_visual(), { noremap = true })
			vim.api.nvim_set_keymap("v", "g<C-a>", require("dial.map").inc_gvisual(), { noremap = true })
			vim.api.nvim_set_keymap("v", "g<C-x>", require("dial.map").dec_gvisual(), { noremap = true })
		end,
	},
	{
		"alexghergh/nvim-tmux-navigation",
		lazy = false,
		config = function()
			local nvim_tmux_nav = require("nvim-tmux-navigation")

				nvim_tmux_nav.setup({
					disable_when_zoomed = false, -- defaults to false
				})

				vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft, { desc = "Tmux Left" })
				vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown, { desc = "Tmux Down" })
				vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp, { desc = "Tmux Up" })
				vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight, { desc = "Tmux Right" })
				vim.keymap.set("n", "<C-g>", nvim_tmux_nav.NvimTmuxNavigateLastActive, { desc = "Tmux Previous Panel" })
				vim.keymap.set("n", "<C-n>", nvim_tmux_nav.NvimTmuxNavigateNext, { desc = "Tmux Next Panel" })
			end,
	},
	{ 
		"mbbill/undotree"
		,lazy = false
		,config = function()
			vim.keymap.set('n', '<C-u>', vim.cmd.UndotreeToggle, { desc="Toggle Undo Tree"})
		end
	},
}
