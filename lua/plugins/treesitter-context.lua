vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter-context" }, { confirm = false })

require("treesitter-context").setup({
	enable = true,
	max_lines = 5,
	mode = "topline",
	multiwindow = true,
})
