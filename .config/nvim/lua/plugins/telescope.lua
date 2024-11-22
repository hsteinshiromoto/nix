return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-file-browser.nvim",
			"cljoly/telescope-repo.nvim",
			"stevearc/aerial.nvim",
			"nvim-telescope/telescope-frecency.nvim",
		},
		cmd = "Telescope",
		keys = {
			-- { "<leader><space>", require("utils").find_files, desc = "Find Files" },
			{ "<leader>ff", require("utils").find_files, desc = "Find Files" },
			{ "<leader>fo", "<cmd>Telescope frecency theme=dropdown<cr>", desc = "Recent" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fr", "<cmd>Telescope file_browser<cr>", desc = "Browser" },
			{ "<leader>ps", "<cmd>Telescope repo list<cr>", desc = "Search" },
			{ "<leader>hs", "<cmd>Telescope help_tags<cr>", desc = "Telescope Tags" },
			{ "<leader>f/", "<cmd>Telescope live_grep<cr>", desc = "Telescode Live Grep" },
			{
				"<leader>/",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find()
				end,
				desc = "Buffer",
			},
			{ "<leader>vo", "<cmd>Telescope aerial<cr>", desc = "Code Outline" },
		},
		config = function(_, _)
			local telescope = require("telescope")
			local icons = require("config.icons")
			local actions = require("telescope.actions")
			local actions_layout = require("telescope.actions.layout")
			local mappings = {
				i = {
					["<C-j>"] = actions.move_selection_next,
					["<C-k>"] = actions.move_selection_previous,
					["<C-n>"] = actions.cycle_history_next,
					["<C-p>"] = actions.cycle_history_prev,
					["?"] = actions_layout.toggle_preview,
				},
			}

			local opts = {
				defaults = {
					prompt_prefix = icons.ui.Telescope .. " ",
					selection_caret = icons.ui.Forward .. " ",
					mappings = mappings,
					border = {},
					borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
					color_devicons = true,
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
					},
				},
				pickers = {
					find_files = {
						previewer = true,
						hidden = true,
						find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
						sorting_strategy = "ascending",
					},
					git_files = {
						previewer = true,
						hidden = true,
					},
					buffers = {
						previewer = true,
					},
					live_grep = {
						file_ignore_patterns = { "node_modules", ".git", ".venv" },
						additional_args = function(_)
							return { "--hidden" }
						end,
					},
				},
				extensions = {
					file_browser = {
						theme = "dropdown",
						previewer = true,
						hijack_netrw = true,
						hidden = true,
						mappings = mappings,
					},
					project = {
						hidden_files = false,
						theme = "dropdown",
					},
				},
			}
			telescope.setup(opts)
			telescope.load_extension("fzf")
			telescope.load_extension("file_browser")
			-- telescope.load_extension("project")
			-- telescope.load_extension("projects")
			telescope.load_extension("aerial")
			telescope.load_extension("dap")
			telescope.load_extension("frecency")
		end,
	},
	{
		"stevearc/aerial.nvim",
		config = true,
	},
}
