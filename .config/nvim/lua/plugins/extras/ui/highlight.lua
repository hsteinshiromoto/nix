return {
	{
		"RRethy/vim-illuminate",
		event = "BufReadPost",
		opts = { delay = 200 },
		config = function(_, opts)
			require("illuminate").configure(opts)
		end,
	},
	{
		"m-demare/hlargs.nvim",
		event = "VeryLazy",
		opts = {
			color = "#ef9062",
			use_colorpalette = false,
			disable = function(_, bufnr)
				if vim.b.semantic_tokens then
					return true
				end
				local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
				for _, c in pairs(clients) do
					local caps = c.server_capabilities
					if c.name ~= "null-ls" and caps.semanticTokensProvider and caps.semanticTokensProvider.full then
						vim.b.semantic_tokens = true
						return vim.b.semantic_tokens
					end
				end
			end,
		},
	},
	{
		"andymass/vim-matchup",
		lazy = false,
		enabled = true,
		init = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
	},
}

-- References:
-- 	[1] https://github.com/alpha2phi/modern-neovim/blob/03-ui/lua/plugins/extras/ui/highlight.lua
