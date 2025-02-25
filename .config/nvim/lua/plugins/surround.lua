return {
	"echasnovski/mini.surround",
	version = "*",
	event = "VeryLazy",
	config = function()
		require("mini.surround").setup({
			-- Add custom surroundings to be used on top of builtin ones. For more
			-- information with examples, see `:h MiniSurround.config`.
			custom_surroundings = {
				s = {
					input = { "%[%[().-()%]%]" },
					output = { left = "[[", right = "]]" },
				},
			},
		})
	end,
}
-- Examples:
-- | keymap | pre-execution | post-execution |
-- | saiw'  | [wo|rd]				| ['word']       |
-- where | is the cursor
