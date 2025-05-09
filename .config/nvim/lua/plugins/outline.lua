return {
	"hedyhli/outline.nvim",
	lazy = false,
	cmd = { "Outline", "OutlineOpen" },
	config = function()
		-- Example mapping to toggle outline
		vim.keymap.set("n", "<leader>co", "<cmd>Outline<CR>", { desc = "Toggle Code Outline" })

		require("outline").setup({
			-- Your setup opts here (leave empty to use defaults)
			outline_items = {
				show_symbol_lineno = true,
			},
			symbols = {
				filter = {
					default = { "String", exclude = true },
				},
			},
		})
	end,
}
