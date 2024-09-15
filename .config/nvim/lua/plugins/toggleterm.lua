return {
	"akinsho/toggleterm.nvim",
	config = function()
		require("toggleterm").setup({})
	end,
	vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>"),
}
