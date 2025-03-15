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
	-- Note: if 'timeoutlen' is low enough to cause occasional usage of |s| key
	-- (that deletes character under cursor), disable it with the following call:
	vim.keymap.set({ "n", "x" }, "s", "<Nop>"),
}
-- Examples:
-- | keymap | pre-execution | post-execution |
-- | saiw'  | [wo|rd]				| ['word']       |
-- where | is the cursor
