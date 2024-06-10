return {
	"akinsho/toggleterm.nvim",
	config = function()
		require("toggleterm").setup({})
	end,
	vim.keymap.set("n", "<leader>s", ":ToggleTerm<CR>"),
}
