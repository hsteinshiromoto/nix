local icons = require("config.icons")

return {
	"luukvbaal/statuscol.nvim",
	event = "VeryLazy",
	ft_ignore = { "neo-tree", "alpha", "Outline" },
	config = function()
		-- vim.opt.relativenumber = true
		local builtin = require("statuscol.builtin")

		require("statuscol").setup({
			relculright = true,
			segments = {
				{
					text = { builtin.foldfunc }, -- Add fold function to segments
					condition = { true },
					click = "v:lua.ScFa",
				},
				{
					text = { builtin.lnumfunc, " " },
					condition = { true, builtin.not_empty },
					click = "v:lua.ScLa",
				}, -- Absolute line numbers
				-- Absolute line numbers
				{ text = { "%s" }, click = "v:lua.ScSa", condition = { true } }, -- git signs
				{
					text = { icons.ui.ThickLeftLine, " " }, -- Status col border
				},
			},
			clickmod = "c", -- modifier used for certain actions in the builtin clickhandlers:
			-- "a" for Alt, "c" for Ctrl and "m" for Meta.
			clickhandlers = { -- builtin click handlers, keys are pattern matched
				Lnum = builtin.lnum_click,
				FoldClose = builtin.foldclose_click,
				FoldOpen = builtin.foldopen_click,
				FoldOther = builtin.foldother_click,
				DapBreakpointRejected = builtin.toggle_breakpoint,
				DapBreakpoint = builtin.toggle_breakpoint,
				DapBreakpointCondition = builtin.toggle_breakpoint,
				["diagnostic/signs"] = builtin.diagnostic_click,
				gitsigns = builtin.gitsigns_click,
			},
		})
	end,
}
