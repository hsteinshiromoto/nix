return {
	"frabjous/knap",
	init = function()
		-- Configure vim.g.knap_settings
	end,
    --stylua: ignore
    keys = {
      { "<leader>np", function() require("knap").process_once() end, desc = "Preview", },
      { "<leader>nc", function() require("knap").close_viewer() end, desc = "Close Preview", },
      { "<leader>nt", function() require("knap").close_viewer() end, desc = "Toggle Preview", },
      { "<leader>nj", function() require("knap").forward_jump() end, desc = "Forward jump", },
    },
	ft = { "markdown", "tex" },
}
