local keymap = vim.keymap.set

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
-- Autosave and quit
-- keymap("n", "zz", ":wqa<CR>", { desc = "Save and quit" })

keymap({ "n", "v" }, "<leader><BS>", "<cmd>nohlsearch<cr>", { desc = "Stop Highlight" })

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
