return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "python" })
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				pyright = {
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "off",
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								diagnosticMode = "workspace",
							},
						},
					},
				},
			},
		},
	},
}

-- References
-- 	[1] https://github.com/alpha2phi/modern-neovim/blob/03-ui/lua/plugins/extras/lang/python.lua
