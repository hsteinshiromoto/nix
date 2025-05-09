return {
	"MagicDuck/grug-far.nvim",
	lazy = false,
	keys = {
		-- { "<leader>gf", "<cmd>GrugFar<cr>", desc = "GrugFar" },
	},
	config = function()
		require("grug-far").setup({
			-- options, see Configuration section below
			-- there are no required options atm
			-- engine = 'ripgrep' is default, but 'astgrep' can be specified
		})
	end,
}
