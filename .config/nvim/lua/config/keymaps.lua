local keymap = vim.keymap.set

keymap("n", "r", "<cmd>red<cr>", { desc = "Undo" })
keymap("n", "<F7>", "a<C-r>=strftime('%Y-%m-%d')<CR><Esc>", { desc = "Insert Today's Date" })

-- Remaps for Tmux Panes: The following comment depends on the tpane file located in .local/bin
keymap("n", "<leader>`", "<cmd>!tpane<CR>", { desc = "Toggle Tmux bottom pane" })

-- Remaps for selection
keymap("n", "$$", "v$h", { noremap = true, silent = true, desc = "Select until end of line" })
keymap("n", "00", "v0", { noremap = true, silent = true, desc = "Select until start of line" })
keymap("n", "S", function()
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	local i = (vim.api.nvim_buf_get_lines(0, ln - 1, ln, false)[1]):find("%a")
	if i then
		vim.api.nvim_win_set_cursor(0, { ln, i - 1 })
		vim.cmd("normal! v$h")
	end
end, { noremap = true, silent = true, desc = "Select whole line excluding start whitespace" })
-- Remaps for quitting
keymap("n", "qq", "<cmd>q!<cr>", { desc = "Quit without save" })

-- Remap for dealing with word wrap [1]
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Better escape using jk in insert and terminal mode [1]
keymap("i", "jk", "<ESC>", { desc = "<ESC>" })
keymap("t", "jk", "<C-\\><C-n>", { desc = "<ESC>" })
keymap("t", "<C-h>", "<C-\\><C-n><C-w>h")
keymap("t", "<C-j>", "<C-\\><C-n><C-w>j")
keymap("t", "<C-k>", "<C-\\><C-n><C-w>k")
keymap("t", "<C-l>", "<C-\\><C-n><C-w>l")

-- Better indent [1]
keymap("v", "<", "<gv", { desc = "Indent Left" })
keymap("v", ">", ">gv", { desc = "Indent Right" })

-- Paste over currently selected text without yanking it [1]
keymap("v", "p", '"_dP', { desc = "Paste over currently selected text without yanking it" })

-- Move Lines [1]
keymap("n", "<A-j>", ":m .+1<CR>==", { desc = "Move Lines" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move Lines" })
keymap("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move Lines" })
keymap("n", "<A-k>", ":m .-2<CR>==", { desc = "Move Lines" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move Lines" })
keymap("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move Lines" })

-- Delete without yanking
keymap({ "n", "v" }, "d", '"_d', { desc = "Delete and not yank" })
keymap({ "n", "v" }, "<del>", '"_d', { desc = "Delete and not yank" })

-- Autosave and quit
-- keymap("n", "zz", ":wqa<CR>", { desc = "Save and quit" })

-- Map <leader>backspace to stop Highlight
keymap({ "n", "v" }, "<leader><BS>", "<cmd>nohlsearch<cr>", { desc = "Stop Highlight" })

-- Map paste above and below current line.
keymap({ "n", "v" }, "<leader>p", ":pu<CR>", { desc = "Past below line" })
keymap({ "n", "v" }, "<leader>P", ":pu!<CR>", { desc = "Past above line" })

-- Remove q as Macro
keymap("n", "q", "<nop>", { noremap = true })

-- Auto Indent the When Inserting New Empty Line[2]
vim.keymap.set("n", "i", function()
	if #vim.fn.getline(".") == 0 then
		return [["_cc]]
	else
		return "i"
	end
end, { expr = true })

-- References
-- 	[1] https://alpha2phi.medium.com/modern-neovim-init-lua-ab1220e3ecc1
-- 	[2] https://alpha2phi.medium.com/modern-neovim-configuration-hacks-93b13283969f
