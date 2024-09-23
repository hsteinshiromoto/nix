return {
	"CRAG666/code_runner.nvim",
	config = function()
		code_runner = require("code_runner")
		code_runner.setup({
			filetype = {
				python = "python3 -u '$dir/$fileName'",
				sh = "bash",
			},
			vim.keymap.set("n", "<localleader>r", ":RunCode<CR>", { noremap = true, silent = false }),
			vim.keymap.set("n", "<localleader>rf", ":RunFile<CR>", { noremap = true, silent = false }),
			vim.keymap.set("n", "<localleader>rft", ":RunFile tab<CR>", { noremap = true, silent = false }),
			vim.keymap.set("n", "<localleader>rp", ":RunProject<CR>", { noremap = true, silent = false }),
			vim.keymap.set("n", "<localleader>rc", ":RunClose<CR>", { noremap = true, silent = false }),
			vim.keymap.set("n", "<localleader>crf", ":CRFiletype<CR>", { noremap = true, silent = false }),
			vim.keymap.set("n", "<localleader>crp", ":CRProjects<CR>", { noremap = true, silent = false }),
		})
	end,
}
