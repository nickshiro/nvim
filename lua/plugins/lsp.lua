vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" }, { confirm = false })

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
		"svelte",
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
	-- "tailwindcss",
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
	"svelte",
	"lisp",
})
