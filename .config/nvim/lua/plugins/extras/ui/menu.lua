return {
	{ "nvzone/volt", lazy = true },
	{ "nvzone/menu", lazy = true },
	{
		vim.keymap.set("n", "<C-t>", function()
			require("menu").open("default")
		end, {}),
		-- mouse users + nvimtree users!
		-- mouse users + nvimtree users!
		vim.keymap.set("n", "<RightMouse>", function()
			vim.cmd.exec('"normal! \\<RightMouse>"')

			local options = vim.bo.ft == "Neotree" and "neotree" or "default"
			require("menu").open(options, { mouse = true })
		end, {}),
	},
}
