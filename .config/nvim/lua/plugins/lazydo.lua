return {
	"Dan7h3x/LazyDo",
	events = "VeryLazy",
	opts = {
		-- your config here
	},
	config = function(_, opts)
		require("lazydo").setup(opts)
	end,
}
