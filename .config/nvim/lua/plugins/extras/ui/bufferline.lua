local icons = require("config.icons")

return {
	"akinsho/bufferline.nvim",
	version = "*",
	lazy = false,
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		vim.opt.termguicolors = true
		local bufferline = require("bufferline")
		bufferline.setup({
			options = {
				mode = "tabs",
				offsets = {
					{
						filetype = "neo-tree",
						text = icons.ui.FolderTree .. " " .. "File Explorer",
						text_align = "center",
						separator = true,
					},
					show_buffer_icons = true, -- disable filetype icons for buffers
					show_buffer_close_icons = true,
					show_close_icon = true,
					show_tab_indicators = true,
					show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
				},
			},
		})
	end,
}
