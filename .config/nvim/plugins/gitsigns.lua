return { "lewis6991/gitsigns.nvim" 
	config = function()
		require('gitsigns').setup({
			signs = { add 	= { text = 'M+' }
				,change	= { text = 'M' }
				,delete = { text = 'M-' }
				,topdelete = { text = '^' }
				,changedelete = { text = '|<' }
			},
		})
	end
}
