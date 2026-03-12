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

vim.lsp.config("ts_ls", {})

vim.lsp.config("prlsp", {
	cmd = { "prlsp" },
	root_markers = { ".git" },
	capabilities = {
		offsetEncoding = { "utf-16" },
	},
})

vim.lsp.config("emmet_language_server", {
	filetypes = {
		"css",
		"html",
		"javascript",
		"javascriptreact",
		"sass",
		"scss",
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

-- vim.lsp.log.set_level('debug')

vim.lsp.enable({
	"ts_ls",
	"cssls",
	"html",
	"gopls",
	-- "tailwindcss",
	"rust_analyzer",
	"jsonls",
	"emmet_language_server",
	"biome",
	"bashls",
	"yamlls",
	"lua_ls",
	"stylua",
	"zls",
	"svelte",
	"prlsp",
})
