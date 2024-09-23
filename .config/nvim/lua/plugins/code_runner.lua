return {
	"CRAG666/code_runner.nvim",
	config = function()
		code_runner = require("code_runner")
		code_runner.setup({
			filetype = {
				python = "python3 -u",
			},
		})
	end,
}
