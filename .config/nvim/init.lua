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

require("lazy").setup("plugins")

-- Setup relative and absolute numbers
-- References:
--	[1] https://www.reddit.com/r/neovim/comments/14xxw1p/display_both_relative_and_absolute_line_numbers/

vim.opt.nu = true
vim.opt.relativenumber = true
vim.o.statuscolumn = "%s %l %r "

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

-- Setup Neotree
vim.keymap.set("n", "<C-k>", ":Neotree filesystem toggle left<CR>")
use_libuv_file_watcher=true
-- Setup Lualine
require('lualine').setup({
	options = { theme = 'gruvbox' },
})

-- Setup Undotree
vim.keymap.set('n', '<C-u>', vim.cmd.UndotreeToggle)

-- Setup Neogit
vim.keymap.set('n', '<C-g>', ":Neogit<CR>")

-- Setup Tab Commands
vim.keymap.set('n', '<C-t>', ":tabnew<CR>")

