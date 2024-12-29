return {
	"echasnovski/mini.surround",
	version = "*",
	event = "VeryLazy",
	config = function()
		require("mini.surround").setup()
	end,
}
-- Examples:
-- | keymap | pre-execution | post-execution |
-- | saiw'  | [wo|rd]				| ['word']       |
-- where | is the cursor
