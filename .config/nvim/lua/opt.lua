-- Setup relative and absolute numbers
-- References:
--	[1] https://www.reddit.com/r/neovim/comments/14xxw1p/display_both_relative_and_absolute_line_numbers/

vim.g.mapleader = " "
vim.g.maplocalleader = ";"

vim.opt.nu = true
vim.opt.relativenumber = true
vim.o.statuscolumn = "%s %l %r "

-- Setup Neotree to open when NeoVim starts
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd("Neotree")
	end,
})

-- Setup NeoVim to yank to clipboard
vim.opt.clipboard = "unnamedplus"

-- update buffer content when file changes externally
vim.opt.autoread = true

-- Autosave and quit
vim.keymap.set("n", "zz", ":wqa<CR>", { desc = "Save and quit" })

-- Highlight on yank
vim.cmd([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]])
