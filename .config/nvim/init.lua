local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("opt")
require("lazy").setup("plugins")

-- Setup Gitgitsigns
require('gitsigns').setup({
	signs = {
		add 	= { text = 'M+' },
		change	= { text = 'M' },
		delete 	= { text = 'M-' },
		topdelete = { text = '^' },
    		changedelete = { text = '|<' },
	},
	}
)

-- Setup Undotree
vim.keymap.set('n', '<C-u>', vim.cmd.UndotreeToggle)

-- Setup Neogit
vim.keymap.set('n', '<C-g>', ":Neogit<CR>")

-- Setup Tab Commands
vim.keymap.set('n', '<C-t>', ":tabnew<CR>")

