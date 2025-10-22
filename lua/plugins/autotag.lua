vim.pack.add(
	{ "https://github.com/windwp/nvim-ts-autotag", "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ confirm = false }
)

local autotag = require("nvim-ts-autotag")

autotag.setup({
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = true,
	},
	filetypes = {
		"html",
		"xml",
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
		"tsx",
		"jsx",
		"markdown",
	},
	skip_tags = { "br", "img", "Image", "hr", "input", "meta", "link" },
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	underline = true,
	virtual_text = {
		spacing = 5,
		severity_limit = "Warning",
	},
	update_in_insert = false,
})
