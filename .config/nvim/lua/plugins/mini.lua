return {
	{
		"echasnovski/mini.map",
		opts = {},
		keys = {
      --stylua: ignore
      { "<leader>vm", function() require("mini.map").toggle {} end, desc = "Toggle Minimap", },
		},
		config = function(_, opts)
			require("mini.map").setup(opts)
		end,
	},
}
