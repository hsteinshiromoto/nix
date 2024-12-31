local keymap = vim.keymap.set

return {
	"arnarg/todotxt.nvim",
	event = "VeryLazy",
	keymap("n", "<leader>ta", "<CMD>ToDoTxtCapture<CR>", { desc = "Add ToDoTxT Task" }),
	keymap("n", "<leader>tg", "<CMD>ToDoTxtTasksToggle<CR>", { desc = "Toggle ToDoTxT Panel" }),
	config = function()
		require("todotxt-nvim").setup({
			todo_file = "todo.txt",
			alternative_priority = {
				A = "now",
				B = "next",
				C = "this week",
				D = "next week",
				E = "next fortnight",
			},
			-- Keymap used in sidebar split
			keymap = {
				quit = "q",
				toggle_metadata = "m",
				delete_task = "dd",
				complete_task = "<space>",
				edit_task = "ee",
			},
		})
	end,
}
-- Format Rules [2]:
-- х (А) 2016-05-20 2016-04-30 measure space for +chapelShelving @chapel due:2016-05-30
-- │ 	│  │ 					│ 				 │ 								 │ 							 │ 			 └──> Special key:value tag
-- │ 	│  │ 					│ 				 │ 								 │ 							 └──────────> Context tag
-- │ 	│  │ 					│ 				 │ 								 └──────────────────────────> Project tag
-- │ 	│  │ 					│ 				 └────────────────────────────────────────────> Description with tags
-- │ 	│  │ 			  	└───────────────────────────────────────────────────────> Creation Date
-- │ 	│  └──────────────────────────────────────────────────────────────────> Completion Date
-- │ 	└─────────────────────────────────────────────────────────────────────> Priority (opt.)
-- └────────────────────────────────────────────────────────────────────────> Completition Marker (opt.)
--
-- References:
-- 	[1] https://github.com/arnarg/todotxt.nvim
-- 	[2] https://github.com/todotxt/todo.txt
