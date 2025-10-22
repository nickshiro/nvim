vim.pack.add({ "https://github.com/Shatur/neovim-session-manager", "https://github.com/nvim-lua/plenary.nvim" }, { confirm = false })

local Path = require("plenary.path")
local config = require("session_manager.config")

require("session_manager").setup({
	sessions_dir = Path:new(vim.fn.stdpath("data"), "sessions"),
	autoload_mode = config.AutoloadMode.CurrentDir,
	autosave_last_session = true,
	autosave_ignore_not_normal = true,
	autosave_ignore_dirs = {},
	autosave_ignore_filetypes = {
		"gitcommit",
		"gitrebase",
	},
	autosave_ignore_buftypes = {},
	autosave_only_in_session = false,
	max_path_length = 80,
	load_include_current = false,
})
