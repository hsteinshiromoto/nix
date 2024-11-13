return {
	"CRAG666/code_runner.nvim",
	dependencies = { "preservim/vimux" },
	config = function()
		code_runner = require("code_runner")
		code_runner.setup({
			mode = "vimux",
			filetype = {
				python = "python3 -u '$dir/$fileName'",
				sh = "bash",
			},
			-- vim.keymap.set("n", "<localleader>r", ":RunCode<CR>", { noremap = true, silent = false }),
			vim.keymap.set("n", "<leader>cr", ":RunFile<CR>", { noremap = true, silent = false }),
			vim.keymap.set("n", "<localleader>ct", ":RunFile tab<CR>", { noremap = true, silent = false }),
			vim.keymap.set("n", "<localleader>cp", ":RunProject<CR>", { noremap = true, silent = false }),
			-- vim.keymap.set("n", "<localleader>rc", ":RunClose<CR>", { noremap = true, silent = false }),
			-- vim.keymap.set("n", "<localleader>crf", ":CRFiletype<CR>", { noremap = true, silent = false }),
			-- vim.keymap.set("n", "<localleader>crp", ":CRProjects<CR>", { noremap = true, silent = false }),
		})
	end,
}
