vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
}, { confirm = false })

vim.cmd.packadd("nvim-treesitter")

local ensure_installed = {
	"bash",
	"query",
	"c",
	"go",
	"gosum",
	"gotmpl",
	"gomod",
	"gowork",
	"json",
	"json5",
	"toml",
	"yaml",
	"html",
	"css",
	"javascript",
	"jsdoc",
	"typescript",
	"tsx",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"rust",
	"make",
	"cmake",
	"ssh_config",
	"dockerfile",
	"nginx",
	"elixir",
	"heex",
	"comment",
	"gitignore",
	"git_config",
	"dockerfile",
}

require("nvim-treesitter").install(ensure_installed)

local filetypes = vim.iter(ensure_installed):map(vim.treesitter.language.get_filetypes):flatten():totable()

vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
	callback = function(ev)
		vim.treesitter.start(ev.buf)
	end,
})

require("treesitter-context").setup({
	enable = true,
	max_lines = 5,
	mode = "topline",
	multiwindow = true,
})
