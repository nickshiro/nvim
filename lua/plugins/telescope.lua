vim.pack.add({
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
}, { confirm = false })

require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			".git/",
			"node_modules/",
			"*.pyc",
			"__pycache__/",
			".zig-cache/",
            -- Elixir
            "_build",
            "deps",
            ".elixir_ls"
		},
	},
	pickers = {
		find_files = {
			find_command = { "rg", "--files", "--hidden", "--glob", "!.git" },
		},
	},
})
