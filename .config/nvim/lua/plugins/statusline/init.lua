return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		config = function()
			local components = require("plugins.statusline.components")
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "gruvbox-material",
					component_separators = {},
					section_separators = {},
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
				tabline = {
					lualine_a = { "mode" },
					lualine_b = { components.git_repo, { "branch", icon = "" } },
					lualine_c = { components.diff, components.diagnostics, components.separator, components.lsp_client },
					lualine_x = { "filename", components.spaces, "encoding", "fileformat", "filetype", "progress" },
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
