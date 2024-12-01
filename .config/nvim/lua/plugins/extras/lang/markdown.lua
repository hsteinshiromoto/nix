local icons = require("config.icons")

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		lazy = false,
		-- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use standalone mini plugins
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			file_types = { "markdown", "Avante" },
		},
		ft = { "markdown", "Avante" },
		config = function()
			require("render-markdown").setup({
				heading = {
					icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
					signs = { "H1", "H2", "H3", "H4", "H5", "H6" },
				},
				checkbox = {
					custom = {
						important = {
							raw = "[!]",
							rendered = icons.ui.AlertTriangle .. " ",
							highlight = "DiagnosticWarn",
						},
						meeting = { raw = "[<]", rendered = icons.ui.Calendar2 .. " " },
					},
				},
			})
		end,
	},
}
