local keymap = vim.keymap.set

return {
	"Dan7h3x/LazyDo",
	branch = "main",
	lazy = false,
	keymap("n", "ld", "<CMD>LazyDoToggle<CR>", { desc = "LazyDo Toggle" }),
	opts = {},
	config = function(_, opts)
		require("lazydo").setup(opts)
	end,
}
