return {
	"alexghergh/nvim-tmux-navigation"
	,
	config = function()
		local nvim_tmux_nav = require("nvim-tmux-navigation")

		nvim_tmux_nav.setup({
			disable_when_zoomed = false, -- defaults to false
		})

		vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft, {desc = "Tmux Left"})
		vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown, {desc = "Tmux Down"})
		vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp, {desc = "Tmux Up"})
		vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight, {desc = "Tmux Right"})
		vim.keymap.set("n", "<C-g>", nvim_tmux_nav.NvimTmuxNavigateLastActive, {desc = "Tmux Previous Panel"})
		vim.keymap.set("n", "<C-n>", nvim_tmux_nav.NvimTmuxNavigateNext)
	end,
}
