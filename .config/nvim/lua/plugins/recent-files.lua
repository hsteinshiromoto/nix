return {
	"smartpde/telescope-recent-files",
	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		require("telescope").load_extension("recent_files")
		-- Map a shortcut to open the picker.
		vim.api.nvim_set_keymap(
			"n",
			"<Leader><Leader>",
			[[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]],
			{ noremap = true, silent = true }
		)
	end,
}
