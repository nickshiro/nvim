vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" }, { confirm = false })

vim.lsp.util.stylize_markdown = function(bufnr, contents, opts)
	contents = vim.lsp.util._normalize_markdown(contents, {
		width = vim.lsp.util._make_floating_popup_size(contents, opts),
	})
	vim.bo[bufnr].filetype = "markdown"
	vim.treesitter.start(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)
	return contents
end

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

vim.lsp.config("elixirls", {
	cmd = { "elixir-ls" },
	filetypes = { "elixir", "eelixir", "heex", "surface" },
	settings = {
		elixirLS = {
			dialyzerEnabled = true,
			fetchDeps = false,
		},
	},
})

vim.lsp.enable({
	"ts_ls",
	"stylua",
	"html",
	"tailwindcss",
	"rust_analyzer",
	"jsonls",
	"emmet_language_server",
	"biome",
	"bashls",
	"yamlls",
	"elixirls",
	"lua_ls",
})
