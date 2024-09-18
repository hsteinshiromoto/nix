-- Setup Treesitter
-- In Linux, TreeSitter requires rust and tree-sitter-cli to be installed [1]. To do this:
-- 	1. Install Rust using the instructions from [2].
-- 	2. Configure cargo to be used with zsh with the command `. "$HOME/.cargo/env"`. Please note the leading dot in this command.
-- 	3. Install treesitter-cli with the command `cargo install tree-sitter-cli`
-- References:
-- 	[1] https://github.com/nvim-treesitter/nvim-treesitter/issues/1097#issuecomment-1368177624
-- 	[2] https://www.rust-lang.org/tools/install
return { "nvim-treesitter/nvim-treesitter"
	,build = ":TSUpdate"
	,config = function()
		local config = require("nvim-treesitter.configs")
		config.setup({	auto_install = true
			,highlight = { enable = true }
			,indent = { enable = true }
			,ensure_installed = {"dockerfile", "html", "latex", "json","lua", "make", "markdown", "markdown_inline", "python", "toml", "yaml", "vim", "vimdoc"}
		})
	end
}

