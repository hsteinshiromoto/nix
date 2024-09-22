return {
	"CRAG666/code_runner.nvim",
	require("code_runner").setup({
		filetype = {
			python = "python3 -u",
		},
	}),
}
