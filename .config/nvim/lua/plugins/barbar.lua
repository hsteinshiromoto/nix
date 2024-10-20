return { 'romgrk/barbar.nvim'
	,dependencies = { 'lewis6991/gitsigns.nvim' -- OPTIONAL: for git status
		,'nvim-tree/nvim-web-devicons' -- OPTIONAL: for file icons
		}
	,event = "BufEnter"
	,config = function()
		require("barbar").setup({})
		vim.keymap.set('n', '<C-t>', ":tabnew<CR>", { desc="Create new tab"} )
		vim.g.barbar_auto_setup = false
	end
}
