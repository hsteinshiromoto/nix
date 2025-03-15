local keymap = vim.keymap.set

keymap("n", "r", "<cmd>red<cr>", { desc = "Undo" })
keymap({ "n", "v" }, "<F8>", function()
	local tomorrow = os.time() + (24 * 60 * 60) -- add 24 hours in seconds
	local date_str = os.date("%Y-%m-%d", tomorrow)
	vim.api.nvim_put({ date_str }, "c", true, true)
end, { desc = "Insert Tomorrow's Date" })
keymap({ "n", "v" }, "<F6>", function()
	local yesterday = os.time() - (24 * 60 * 60) -- subtract 24 hours in seconds
	local date_str = os.date("%Y-%m-%d", yesterday)
	vim.api.nvim_put({ date_str }, "c", true, true)
end, { desc = "Insert Yesterday's Date" })
keymap({ "n", "v" }, "<F7>", "a<C-r>=strftime('%Y-%m-%d')<CR><Esc>", { desc = "Insert Today's Date" })

-- Remaps for Tmux Panes: The following comment depends on the tpane file located in .local/bin
keymap("n", "<leader>`", "<cmd>!tpane<CR>", { desc = "Toggle Tmux bottom pane" })

-- Remaps for selection
keymap("n", "$$", "v$h", { noremap = true, silent = true, desc = "Select until end of line" })
keymap("n", "00", "v0", { noremap = true, silent = true, desc = "Select until start of line" })
keymap("n", "SS", function()
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	local i = (vim.api.nvim_buf_get_lines(0, ln - 1, ln, false)[1]):find("%a")
	if i then
		vim.api.nvim_win_set_cursor(0, { ln, i - 1 })
		vim.cmd("normal! v$h")
	end
end, { noremap = true, silent = true, desc = "Select whole line excluding start whitespace" })
-- Remaps for quitting
keymap("n", "qq", "<cmd>qa!<cr>", { desc = "Quit without save" })

-- Remaps for copying
keymap("n", "cc", "cc<esc>", { desc = "Cut and go into normal mode" })

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
keymap("n", "<", "v<gv", { desc = "Indent Left" })
keymap("n", ">", "v>gv", { desc = "Indent Right" })

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
keymap({ "n", "v" }, "\\", "<cmd>nohlsearch<cr>", { desc = "Stop Highlight" })

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

-- ---
-- The following code move the cursor to the end of a surrounding.
-- ---
function move_to_surrounded_word_end()
	local line = vim.fn.getline(".")
	local col = vim.fn.col(".")
	local char_under_cursor = string.sub(line, col, col)

	-- Define pairs of surrounding characters
	local pairs = {
		["("] = ")",
		["["] = "]",
		["{"] = "}",
		["'"] = "'",
		['"'] = '"',
		["<"] = ">",
	}

	-- Find the end of the surrounded text
	local depth = 1
	local matching_char = pairs[char_under_cursor]
	local i = col + 1

	-- If we're not on an opening character, search backward first to find one
	if not matching_char then
		local matching_char_pos = math.huge -- Initialize with a very large value

		for open_char, close_char in pairs(pairs) do
			local open_pos = string.find(string.sub(line, 1, col), open_char .. ".*$")
			if open_pos then
				local close_pos = string.find(line, close_char, col)
				if close_pos and (close_pos < matching_char_pos) then
					matching_char = close_char
					matching_char_pos = close_pos
					i = open_pos + 1
					char_under_cursor = open_char
				end
			end
		end
	end

	if matching_char then
		while i <= #line do
			local curr_char = string.sub(line, i, i)

			if curr_char == char_under_cursor then
				depth = depth + 1
			elseif curr_char == matching_char then
				depth = depth - 1
				if depth == 0 then
					-- Move to one position before the closing character
					vim.fn.cursor(vim.fn.line("."), i - 1)
					return
				end
			end

			i = i + 1
		end
	end
end

-- Map it to a key combination, for example <leader>e
vim.api.nvim_set_keymap(
	"n",
	"<leader>se",
	"<cmd>lua move_to_surrounded_word_end()<CR>",
	{ noremap = true, silent = true, desc = "Move cursor to the end of a surround" }
)

-- ---
-- End
-- ---

-- References
-- 	[1] https://alpha2phi.medium.com/modern-neovim-init-lua-ab1220e3ecc1
-- 	[2] https://alpha2phi.medium.com/modern-neovim-configuration-hacks-93b13283969f
