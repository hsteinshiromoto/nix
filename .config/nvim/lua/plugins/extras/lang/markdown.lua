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
		cond = vim.fn.isdirectory(".obsidian") == 0,
		config = function()
			require("render-markdown").setup({
				heading = {
					icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
					signs = { "H1", "H2", "H3", "H4", "H5", "H6" },
				},
				bullet = {
					enabled = true,
					icons = { "•", ">", ">>", ">>>" },
					ordered_icons = {},
					left_pad = 0,
					right_pad = 1,
					highlight = "RenderMarkdownBullet",
				},
				checkbox = {
					custom = {
						cancelled = {
							raw = "[x]",
							rendered = icons.ui.CloseBox .. " ",
							highlight = "RenderMarkdownChecked",
							scope_highlight = "@markup.strikethrough",
						},
						done = {
							raw = "[v]",
							rendered = icons.ui.BoxChecked2 .. " ",
							highlight = "RenderMarkdownChecked",
							scope_highlight = "@markup.strikethrough",
						},
						important = {
							raw = "[!]",
							rendered = icons.ui.AlertTriangle .. " ",
							highlight = "DiagnosticWarn",
						},
						meeting = {
							raw = "[<]",
							rendered = icons.ui.Calendar2 .. " ",
							highlight = "RenderMarkdownTodo",
							scope_highlight = nil,
						},
						todo = {
							raw = "[ ]",
							rendered = icons.ui.CheckBox .. " ",
							highlight = "RenderMarkdownTodo",
							scope_highlight = nil,
						},
						incomplete = {
							raw = "[/]",
							rendered = icons.ui.MinusSquare .. " ",
							highlight = "DiagnosticWarn",
							scope_highlight = nil,
						},
					},
				},
			})
		end,
	},
	{
		"hsteinshiromoto/markdown_mover.nvim", -- For GitHub hosted plugin
		-- or local plugin in your config
		-- dir = "~/path/to/markdown-mover.nvim",
		-- dev = true, -- For local development
		lazy = false,
		ft = "markdown",
		config = function()
			require("markdown_mover").setup({
				tag_field = "tags", -- The name of the frontmatter field containing tags
				tag_rules = {},
				default_path = nil, -- Default path if no matching tag (nil to disable)
				auto_move = false, -- Move files automatically on save
				verbose = true, -- Show notifications
				keymap = "<leader>mm", -- Keymap for manual moving (empty to disable)
				ignore_dirs = { -- Directories to ignore (can be patterns)
					".*/meta/.*", -- Ignore meta directories
					".*/logs/.*", -- Ignore log directories
					".*/src/.*", -- Ignore source code directories
					".*/notebooks/.*", -- Ignore notebook directories
					"~/Documents/archive/.*", -- Additional custom ignore patterns
				},
			})
		end,
	},
}
