local icons = require("config.icons")

return {
	{
		"kevinhwang91/nvim-ufo",
		event = "VeryLazy",
		ft_ignore = { "neo-tree", "alpha", "Outline" },
		dependencies = {
			"kevinhwang91/promise-async",
			"neovim/nvim-lspconfig",
			{
				-- FIX This plugin is rainins the error message: E36: Not enought room.
				--
				-- TODO: It looks like gitsigns has a priority over this plygin, as it does not highlight lines highlighted by gitsigns. Investigate how it can highlight the line number column.
				--
				-- TODO Change pallete to Gruvbox
				"sethen/line-number-change-mode.nvim",
				lazy = false,
				config = function()
					require("catppuccin").setup({
						flavour = "mocha",
					})
					local palette = require("catppuccin.palettes").get_palette("mocha")

					if palette == nil then
						return nil
					end

					require("line-number-change-mode").setup({
						number = true,
						relativenumber = false,
						trigger_events = { "InsertEnter", "InsertLeave" },
						mode = {
							i = {
								bg = palette.green,
								fg = palette.mantle,
								bold = true,
							},
							n = {
								bg = palette.blue,
								fg = palette.mantle,
								bold = true,
							},
							R = {
								bg = palette.maroon,
								fg = palette.mantle,
								bold = true,
							},
							v = {
								bg = palette.mauve,
								fg = palette.mantle,
								bold = true,
							},
							V = {
								bg = palette.mauve,
								fg = palette.mantle,
								bold = true,
							},
						},
					})
				end,
			},
			{
				"luukvbaal/statuscol.nvim",
				lazy = false,
				config = function()
					vim.opt.number = true
					-- vim.opt.relativenumber = true
					local builtin = require("statuscol.builtin")

					require("statuscol").setup({
						relculright = true,
						segments = {
							{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },
							{ text = { "%s", " " }, colwidth = 1, maxwidth = 1, auto = false, click = "v:lua.ScSa" }, -- git signs
							{ text = { "%=", "%l " }, click = "v:lua.ScLa" }, -- Absolute line numbers

							-- { text = { "%r " }, click = "v:lua.ScLa" }, -- Relative line numbers
							-- FIX: Bugs with the following code block. Need to add Diagnostic.
							-- {
							-- 	sign = {
							-- 		namespace= { "Diagnostic" },
							-- 		maxwidth = 2,
							-- 		auto = true,
							-- 	},
							-- 	click = "v:lua.ScSa",
							-- },
						},
					})
				end,
			},
			{
				"lewis6991/gitsigns.nvim",
				lazy = false,
				config = function()
					require("gitsigns").setup({
						signs = {
							add = { text = icons.ui.ThickLeftLine .. "+" },
							change = { text = icons.ui.ThickLeftLine .. icons.ui.PlusMinus },
							delete = { text = icons.ui.ThickLeftLine .. "-" },
							topdelete = { text = icons.ui.ThickLeftLine .. icons.ui.ChevronUp },
							changedelete = { text = icons.ui.ThickLeftLine .. icons.ui.Cross },
							untracked = { text = "┆" },
						},
						signs_staged = {
							add = { text = icons.ui.ThickLeftLine .. "+" },
							change = { text = icons.ui.ThickLeftLine .. icons.ui.PlusMinus },
							delete = { text = icons.ui.ThickLeftLine .. "-" },
							topdelete = { text = icons.ui.ThickLeftLine .. icons.ui.ChevronUp },
							changedelete = { text = icons.ui.ThickLeftLine .. icons.ui.Cross },
							untracked = { text = "┆" },
						},
						-- Highlight also the line number
						numhl = true,
					})
				end,
			},
		},
		-- The following settings for nvim-ufo are from [2].
		init = function()
			vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
			vim.o.foldcolumn = "auto:1" -- '0' is not bad [1]
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
		end,
		opts = {
			-- INFO: Use treeitter as fold provider (better for markdown), otherwise nvim lsp is used
			provider_selector = function(bufnr, filetype, buftype)
				return { "treesitter", "indent" }
			end,
			open_fold_hl_timeout = 400,
			close_fold_kinds = { "imports", "comment" },
			preview = {
				win_config = {
					border = { "", "─", "", "", "", "─", "", "" },
					winhighlight = "Normal:Folded",
					winblend = 0,
				},
				mappings = {
					scrollU = "<C-k>",
					scrollD = "<C-j>",
					jumpTop = "[",
					jumpBot = "]",
				},
			},
		},
		config = function(_, opts)
			local handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local totalLines = vim.api.nvim_buf_line_count(0)
				local foldedLines = endLnum - lnum
				local suffix = ("  %d %d%%"):format(foldedLines, foldedLines / totalLines * 100)
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth
				local curWidth = 0
				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, { chunkText, hlGroup })
						chunkWidth = vim.fn.strdisplaywidth(chunkText)
						-- str width returned from truncate() may less than 2nd argument, need padding
						if curWidth + chunkWidth < targetWidth then
							suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end
				local rAlignAppndx = math.max(math.min(vim.opt.textwidth["_value"], width - 1) - curWidth - sufWidth, 0)
				suffix = (" "):rep(rAlignAppndx) .. suffix
				table.insert(newVirtText, { suffix, "MoreMsg" })
				return newVirtText
			end
			opts["fold_virt_text_handler"] = handler
			require("ufo").setup(opts)
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
			vim.keymap.set("n", "K", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					-- vim.lsp.buf.hover()
					vim.cmd([[ Lspsaga hover_doc ]])
				end
			end)
		end,
	},
	{ "anuvyklack/fold-preview.nvim", dependencies = "anuvyklack/keymap-amend.nvim", config = true, lazy = false },
}
-- References:
-- 	[1] https://github.com/kevinhwang91/nvim-ufo/issues/4#issuecomment-2241159750
-- 	[2] https://github.com/kevinhwang91/nvim-ufo/issues/4#issuecomment-1514537245
