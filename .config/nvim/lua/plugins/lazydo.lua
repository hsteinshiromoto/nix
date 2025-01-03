return {
	"Dan7h3x/LazyDo",
	branch = "main",
	lazy = false,
	opts = {},
	config = function(_, opts)
		require("lazydo").setup(opts)
	end,
}
