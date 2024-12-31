return {
	"arnarg/todotxt.nvim",
	event = "VeryLazy",
	config = function()
		require("todotxt-nvim").setup({
			todo_file = "todo.txt",
		})
	end,
}
