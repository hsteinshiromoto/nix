return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
	--   "BufReadPre path/to/my-vault/**.md",
	--   "BufNewFile path/to/my-vault/**.md",
	-- },
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",

		-- see below for full list of optional dependencies 👇
	},
	keys = {
		{ "<leader>obl", "<cmd>ObsidianBacklinks<cr>", desc = "Obsidian Backlinks" },
		{ "<leader>ofl", "<cmd>ObsidianFollowLink vsplit<cr>", desc = "Obsidian Follow Link" },
		},
	config = function()
		require("obsidian").setup({
			disable_frontmatter = true,
			workspaces = {
			{
				name = "Personal",
				path = "~/Personal",
			},
			{
				name = "Zettelkasten",
				path = "~/zettelkasten",
			},

			-- see below for full list of options 👇
			},
			templates = {
				folder = "_meta_/_templates_",
			},
		})
	end
}
---
--- Required OS packages
--- 	ripgrep: https://github.com/BurntSushi/ripgrep?tab=readme-ov-file#installation
---	pngpaste (for MacOS), wl-clipboard (Wayland) (For Linux)
