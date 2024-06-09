return { "nvim-neo-tree/neo-tree.nvim"
	,dependencies = { "nvim-lua/plenary.nvim"
		,"nvim-tree/nvim-web-devicons" -- not strictly required, but recommended
		,"MunifTanjim/nui.nvim"
      		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    			}
	,config = function()
		vim.keymap.set("n", "<C-k>", ":Neotree filesystem toggle left<CR>")
		use_libuv_file_watcher=true
	end
}
