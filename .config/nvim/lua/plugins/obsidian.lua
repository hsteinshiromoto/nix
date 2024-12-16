local icons = require("config.icons")
local function tchelper(first, rest)
	return first:upper() .. rest:lower()
end
local function make_id()
	local suffix = ""
	for _ = 1, 4 do
		suffix = suffix .. string.char(math.random(65, 90))
	end
	return tostring(os.date("%Y-%m-%d")) .. "_" .. suffix
end
local function basename_func(title)
	-- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
	-- In this case a note with the title 'My new note' will be given an ID that looks
	-- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
	local suffix = ""
	if title ~= nil then
		-- If title is given, transform it into valid file name.
		suffix =
			title:gsub(" ", "_"):gsub("[^A-Za-z0-9-]", " "):gsub("(%a)([%w_']*)", tchelper):gsub("[^A-Za-z0-9-]", "_")
		suffix = tostring(os.date("%Y-%m-%d")) .. "_" .. suffix
	else
		-- If title is nil, just add 4 random uppercase letters to the suffix.
		suffix = make_id()
	end
	return suffix
end

return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
	--   -- refer to `:h file-pattern` for more examples
	--   "BufReadPre path/to/my-vault/*.md",
	--   "BufNewFile path/to/my-vault/*.md",
	-- },
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- see below for full list of optional dependencies 👇
	},
	-- Add condition to only load plugin if directory .obsidian is present [1, 2]
	cond = vim.fn.isdirectory(".obsidian") == 1,
	keys = {

		{ "<localleader>t", "<cmd>ObsidianTemplate<cr>", desc = "Insert Template" },
		{ "<localleader>n", "<cmd>ObsidianNewFromTemplate<cr>", desc = "New Note From Template" },
		{ "<localleader>d", "<cmd>ObsidianToday<cr>", desc = "Obsidian Daily Note" },
		{ "<localleader>l", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
	},
	new_notes_location = "notes_subdir",
	opts = {
		ui = {
			enable = true,
			checkboxes = {
				["<"] = { char = icons.ui.Calendar2, hl_group = "ObsidianDone" },
				["/"] = { char = icons.ui.MinusSquare, hl_group = "ObsidianImportant" },
				[" "] = { char = icons.ui.CheckBox, hl_group = "ObsidianTodo" },
				["-"] = { char = icons.ui.MinusSquare, hl_group = "ObsidianDone" },
				["x"] = { char = icons.ui.BoxChecked2, hl_group = "ObsidianDone" },
				[">"] = { char = "", hl_group = "ObsidianRightArrow" },
				["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
				["!"] = { char = icons.ui.AlertTriangle, hl_group = "ObsidianImportant" },
				["i"] = { char = icons.diagnostics.Information, hl_group = "ObsidianDone" },
			},
		},
		workspaces = {
			{
				name = "personal",
				path = "~/Personal",
			},
			{
				name = "LOR",
				path = "~/Work/LOR",
			},
		},
		templates = {
			folder = "_meta_/_templates_",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			-- A map for custom variables, the key should be the variable and the value a function
			substitutions = {},
		},
		-- Optional, customize how note IDs are generated given an optional title.
		---@return string
		note_id_func = function()
			return make_id()
		end,
		-- Optional, customize how note file names are generated given the ID, target directory, and title.
		---@param spec { id: string, dir: obsidian.Path, title: string|? }
		---@return string|obsidian.Path The full path to the new note.
		note_path_func = function(spec)
			local basename = basename_func(spec.title)
			-- This is equivalent to the default behavior.
			local path = spec.dir / tostring(basename)
			return path:with_suffix(".md")
		end,
		-- Optional, alternatively you can customize the frontmatter data.
		---@return table
		note_frontmatter_func = function(note)
			local date_created = tostring(os.date("%Y-%m-%d"))
			-- Add the title of the note as an alias.
			if note.title then
				note:add_alias(date_created .. " " .. note.title)
			end
			-- Add the note id as an alias
			if note.id then
				note:add_alias(note.id)
			end

			local out = {
				aliases = note.aliases,
				date_created = date_created,
				id = note.id,
				tags = note.tags,
				title = note.title,
			}

			-- `note.metadata` contains any manually added fields in the frontmatter.
			-- So here we just make sure those fields are kept in the frontmatter.
			if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
				for k, v in pairs(note.metadata) do
					out[k] = v
				end
			end

			return out
		end,
	},
}
-- References:
--   [1] https://stackoverflow.com/questions/67259998/neovim-lua-isdirectory-vim-function
--   [2] https://github.com/LazyVim/LazyVim/discussions/2600#discussioncomment-8572894
