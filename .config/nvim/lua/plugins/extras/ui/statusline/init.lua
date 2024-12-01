local icons = require("config.icons")

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		config = function()
			local components = require("plugins.extras.ui.statusline.components")
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "gruvbox-material",
					component_separators = { left = icons.ui.DividerRight, right = icons.ui.DividerLeft },
					section_separators = { left = icons.ui.BoldDividerRight, right = icons.ui.BoldDividerLeft },
					disabled_filetypes = {
						statusline = { "alpha", "lazy" },
						winbar = {
							"help",
							"alpha",
							"lazy",
						},
					},
					always_divide_middle = true,
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						components.workspace,
						{ "branch", icon = icons.git.Branch },
						components.git_repo,
						components.diff,
					},
					lualine_c = { components.diagnostics, components.lsp_client },
					lualine_x = {
						components.separator,
						components.spaces,
						"encoding",
						"fileformat",
						"filetype",
						components.word_count,
						"progress",
					},
					lualine_y = {},
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				extensions = { "nvim-tree", "toggleterm", "quickfix" },
			})
		end,
	},
}

-- References:
-- 	[1] https://alpha2phi.medium.com/modern-neovim-lsp-and-remote-development-9b1250ee6aee
