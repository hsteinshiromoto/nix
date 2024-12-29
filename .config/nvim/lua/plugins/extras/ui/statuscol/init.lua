local icons = require("config.icons")
local statuscolumn = {}
statuscolumn.border = function()
	-- See how the characters is larger then the rest? That's how we make the border look like a single line
	return "│"
end

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
				{
					text = { "│" },
				},
			},
		})
	end,
}
