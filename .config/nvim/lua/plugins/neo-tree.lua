return {
	"nvim-neo-tree/neo-tree.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	config = function()
		require("neo-tree").setup({
			filesystem = {
				filtered_items = {
					visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
					hide_dotfiles = false,
					hide_gitignored = false,
				},
				use_libuv_file_watcher = true,
				view = { adaptive_size = true },
			},
			event_handlers = {
				{
					event = "file_open_requested",
					handler = function()
						-- auto close
						-- vim.cmd("Neotree close")
						-- Autofocus when a file is opened
						require("neo-tree.command").execute({ action = "focus" })
						-- Autoopen Neotree Buffers, when a file is opened
						-- require("neo-tree.command").execute({ action = "show", source = "buffers", position = "right" })
					end,
				},
			},
			window = {
				mappings = { -- Switch between the following NetoTree modes
					["f"] = function()
						vim.api.nvim_exec("Neotree focus filesystem left", true)
					end,
					["b"] = function()
						vim.api.nvim_exec("Neotree focus buffers left", true)
					end,
					["g"] = function()
						vim.api.nvim_exec("Neotree focus git_status left", true)
					end,
				},
			},
		})
		-- vim.keymap.set("n", ".", ":Neotree filesystem toggle left<CR>", { desc = "Toggle Left File Tree" })
		-- vim.keymap.set("n", ",", ":Neotree buffers toggle float<CR>", { desc = "Toggle Floating Buffer Tree" })
	end,
}
