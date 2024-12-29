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

-- ---
-- Line numbers
-- ---
vim.opt.number = true

-- ---
-- Fold Configuration
--
-- References:
-- 	[1] https://github.com/kevinhwang91/nvim-ufo/issues/4#issuecomment-1514537245
-- ---
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldcolumn = "auto:1" -- '0' is not bad [1]
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
