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
			vim.keymap.set({ "n", "v" }, "<leader>]", "<cmd>BufferLineCycleNext<cr>", { desc = "Buffer Cycle Next" }),
			vim.keymap.set(
				{ "n", "v" },
				"<leader>[",
				"<cmd>BufferLineCyclePrev<cr>",
				{ desc = "Buffer Cycle Previous" }
			),
			options = {
				mode = "tabs",
				style_preset = {
					bufferline.style_preset.no_italic,
					bufferline.style_preset.no_bold,
				},
				offsets = {
					{
						filetype = "neo-tree",
						text = icons.ui.FolderTree .. " " .. "File Explorer",
						text_align = "center",
						separator = false,
					},
					{
						filetype = "Outline",
						text = icons.ui.Code .. " " .. "Code Outline",
						text_align = "center",
						separator = false,
					},
					indicator = {
						style = "underline",
					},
					show_buffer_icons = true, -- disable filetype icons for buffers
					show_buffer_close_icons = true,
					show_close_icon = true,
					show_tab_indicators = true,
					show_duplicate_prefix = true, -- whether to show duplicate buffer prefix
					separator_style = "thick",
				},
			},
		})
	end,
}
