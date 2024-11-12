-- resize splits if the window itself is resized [2]

local autogroup = vim.api.nvim_create_augroup
local localGroup = autogroup("DMS", {})
local autocmd = vim.api.nvim_create_autocmd
-- resize splits if the window itself is resized [2]
autocmd("VimResized", {
	group = localGroup,
	callback = function()
		local currentTab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. currentTab)
	end,
})

-- Highlight in Yank [2]
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- Check if we need to reload the file when it changed [2]
vim.api.nvim_create_autocmd("FocusGained", { command = "checktime" })

-- Show cursor line only in active window [2]
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
	callback = function()
		local ok, cl = pcall(vim.api.nvim_win_get_var, 0, "auto-cursorline")
		if ok and cl then
			vim.wo.cursorline = true
			vim.api.nvim_win_del_var(0, "auto-cursorline")
		end
	end,
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
	callback = function()
		local cl = vim.wo.cursorline
		if cl then
			vim.api.nvim_win_set_var(0, "auto-cursorline", cl)
			vim.wo.cursorline = false
		end
	end,
})

-- Go to last loc when opening a buffer [2]
-- vim.api.nvim_create_autocmd("BufReadPre", {
--   pattern = "*",
--   callback = function()
--     vim.api.nvim_create_autocmd("FileType", {
--       pattern = "<buffer>",
--       once = true,
--       callback = function()
--         vim.cmd(
--           [[if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif]]
--         )
--       end,
--     })
--   end,
-- })

--- References:
--- 	[1] https://www.dmsussman.org/resources/neovimsetup/
---	  [2] https://alpha2phi.medium.com/modern-neovim-init-lua-ab1220e3ecc1
