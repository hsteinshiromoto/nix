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

-- Go to last loc when opening a buffer [2]
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*",
  callback = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "<buffer>",
      once = true,
      callback = function()
        vim.cmd(
          [[if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif]]
        )
      end,
    })
  end,
})

--- References:
--- 	[1] https://www.dmsussman.org/resources/neovimsetup/
---	[2] https://alpha2phi.medium.com/modern-neovim-init-lua-ab1220e3ecc1

