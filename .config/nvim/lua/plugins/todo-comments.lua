return {
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = "BufReadPost",
		config = true,
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next ToDo" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous ToDo" },
      { "<leader>bt", "<cmd>TodoTrouble<cr>", desc = "ToDo (Trouble)" },
      { "<leader>bT", "<cmd>TodoTelescope<cr>", desc = "ToDo" },
      { "<leader>td", "<cmd>TodoLocList<cr>", desc = "ToDo Location List" },
    },
		opts = {
			signs = true,
		},
	},
}
