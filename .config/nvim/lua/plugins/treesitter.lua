-- Setup Treesitter
-- In Linux, TreeSitter requires rust and tree-sitter-cli to be installed [1]. To do this:
-- 	1. Install Rust using the instructions from [2].
-- 	2. Configure cargo to be used with zsh with the command `. "$HOME/.cargo/env"`. Please note the leading dot in this command.
-- 	3. Install treesitter-cli with the command `cargo install tree-sitter-cli`
-- References:
-- 	[1] https://github.com/nvim-treesitter/nvim-treesitter/issues/1097#issuecomment-1368177624
-- 	[2] https://www.rust-lang.org/tools/install
return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		build = ":TSUpdate",
		event = "BufReadPost",
		config = function()
			local swap_next, swap_prev = (function()
				local swap_objects = {
					p = "@parameter.inner",
					f = "@function.outer",
					c = "@class.outer",
				}

				local n, p = {}, {}
				for key, obj in pairs(swap_objects) do
					n[string.format("<leader>cx%s", key)] = obj
					p[string.format("<leader>cX%s", key)] = obj
				end

				return n, p
			end)()

			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash",
					"dockerfile",
					"html",
					"latex",
					"json",
					"lua",
					"make",
					"markdown",
					"markdown_inline",
					"python",
					"query",
					"regex",
					"toml",
					"yaml",
					"vim",
					"vimdoc",
				},
				sync_install = false,
				auto_install = true,
				ignore_install = { "javascript" },
				modules = {},
				highlight = { enable = true },
				indent = { enable = true, disable = { "python" } },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn",
						node_incremental = "grn",
						scope_incremental = "grc",
						node_decremental = "grm",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = swap_next,
						swap_previous = swap_prev,
					},
				},
			})
		end,
	},
}
