vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" }, { confirm = false })

-- vim.lsp.util.stylize_markdown = function(bufnr, contents, opts)
-- 	contents = vim.lsp.util._normalize_markdown(contents, {
-- 		width = vim.lsp.util._make_floating_popup_size(contents, opts),
-- 	})
-- 	vim.bo[bufnr].filetype = "markdown"
-- 	vim.treesitter.start(bufnr)
-- 	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)
-- 	return contents
-- end
--

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

vim.lsp.config("elixir-ls", {
	cmd = { "elixir-ls" },
	filetypes = { "elixir", "eelixir", "heex", "surface" },
	settings = {
		elixirLS = {
			dialyzerEnabled = true,
			fetchDeps = false,
		},
	},
})

vim.lsp.config("emmet-ls", {
	cmd = { "~/w/emmet-ls/zig-out/bin/emmet_ls" },
	filetypes = { "html", "css", "typescriptreact" },
})

vim.lsp.config("emmet_language_server", {
	filetypes = {
		"css",
		"eruby",
		"html",
		"javascript",
		"javascriptreact",
		"less",
		"sass",
		"scss",
		"pug",
		"typescriptreact",
	},
})

for _, lang in pairs({ "lua_ls", "ts_ls" }) do
	vim.lsp.config(lang, {
		on_init = function(p)
			p.server_capabilities.documentFormattingProvider = false
		end,
	})
end

vim.lsp.enable({
	"ts_ls",
	"cssls",
	"html",
    "gopls",
	"tailwindcss",
	"rust_analyzer",
	"jsonls",
	"emmet_language_server",
    -- "emmet_ls",
	"biome",
	"bashls",
	"yamlls",
	"elixir-ls",
	"lua_ls",
	"stylua",
	"zls",
})
