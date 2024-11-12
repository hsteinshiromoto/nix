return {
	{ "stevearc/resession.nvim", opts = {} },
	{
		"scottmckendry/telescope-resession.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		-- config = function()
		-- 	require("telescope").extensions.resession.resession()
		-- end,
	},
}
