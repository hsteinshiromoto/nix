return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim"		-- Only one of these is needed, not both.
, -- optional - Diff integration
		"nvim-telescope/telescope.nvim", -- optional
		-- "ibhagwan/fzf-lua",              -- optional
	},
	config = function()
		vim.keymap.set("n", "<C-g>", ":Neogit<CR>")
	end,
}
