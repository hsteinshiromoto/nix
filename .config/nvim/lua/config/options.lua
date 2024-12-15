local indent = 2

vim.opt.shiftwidth = indent
vim.opt.tabstop = indent
vim.opt.ignorecase = true

-- Setup relative and absolute numbers
-- References:
--	[1] https://www.reddit.com/r/neovim/comments/14xxw1p/display_both_relative_and_absolute_line_numbers/

vim.g.mapleader = " "
vim.g.maplocalleader = ";"

-- Setup Neotree to open when NeoVim starts
-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	callback = function()
-- 		vim.cmd("Neotree")
-- 	end,
-- })

-- Setup NeoVim to yank to clipboard
vim.opt.clipboard = "unnamedplus"

-- update buffer content when file changes externally
vim.opt.autoread = true

vim.opt.cursorline = true
vim.opt.conceallevel = 2
vim.g.have_nerd_font = true
