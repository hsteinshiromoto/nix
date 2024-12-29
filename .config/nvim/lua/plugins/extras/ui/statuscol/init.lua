local icons = require("config.icons")

return {
	"luukvbaal/statuscol.nvim",
	lazy = false,
	config = function()
		-- vim.opt.relativenumber = true
		local builtin = require("statuscol.builtin")

		require("statuscol").setup({
			relculright = true,
			segments = {
				{
					text = { builtin.lnumfunc, " " },
					condition = { true, builtin.not_empty },
					click = "v:lua.ScLa",
				}, -- Absolute line numbers
				{ text = { "%s" }, click = "v:lua.ScSa", condition = { true, builtin.not_empty } }, -- git signs
				{
					text = { builtin.foldfunc, " " },
					condition = { true, builtin.not_empty },
					click = "v:lua.ScFa",
				},
			},
		})
	end,
}
