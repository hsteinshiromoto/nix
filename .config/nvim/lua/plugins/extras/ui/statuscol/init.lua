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
				"luukvbaal/statuscol.nvim",
				lazy = false,
				config = function()
					-- vim.opt.relativenumber = true
					local builtin = require("statuscol.builtin")

					require("statuscol").setup({
						relculright = true,
						segments = {
							{
								text = { builtin.lnumfunc, " " },
								condition = { true, builtin.not_empty },
								click = "v:lua.ScLa",
							}, -- Absolute line numbers
							{ text = { "%s" }, click = "v:lua.ScSa", condition = { true, builtin.not_empty } }, -- git signs
							{
								text = { builtin.foldfunc, " " },
								condition = { true, builtin.not_empty },
								click = "v:lua.ScFa",
							},
						},
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

			-- vim.opt.signcolumn = "auto:2"
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
