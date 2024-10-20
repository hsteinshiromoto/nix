return {
	"romgrk/barbar.nvim",
	dependencies = {
		"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
		"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
	},
	event = "BufEnter",
	config = function()
		require("barbar").setup({})
		vim.keymap.set("n", "<C-t>", ":tabnew<CR>", { desc = "Create New Tab" })
		-- Move to previous/next
		vim.keymap.set('n', '<leader><Left>', '<Cmd>BufferPrevious<CR>', { desc = "Previous Tab" })
		vim.keymap.set('n', '<leader><Right>', '<Cmd>BufferNext<CR>', { desc = "Next tab" })
		vim.g.barbar_auto_setup = false
	end,
}
