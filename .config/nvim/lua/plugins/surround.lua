return {
	"kylechui/nvim-surround",
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	event = "VeryLazy",
	config = function()
		require("nvim-surround").setup({
			-- Configuration here, or leave empty to use defaults
		})
	end,
}
-- NOTE: Use :h nvim-surround.usage to check how to apply this plugin
-- Example:
--    Old text                    Command         New text ~
--    local str = *               <C-g>s"         local str = "*"
--    local tab = *               <C-g>s}         local str = {*}
--    local str = |some text|     S]              local str = [some text]
--    |div id="test"|</div>       S>              <div id="test"></div>
