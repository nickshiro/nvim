return {
	"stevearc/conform.nvim",
	name = "formatter",
	event = "BufReadPre",
	opts = {
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			lua = { "stylua" },
			sh = { "shfmt" },
			python = { "isort", "black" },
			rust = { "rustfmt" },
			html = { "biome" },
			css = { "biome" },
			json = { "biome" },
			yaml = { "biome" },
			javascript = { "biome" },
			javascriptreact = { "biome" },
			typescript = { "biome" },
			typescriptreact = { "biome" },
		},
		formatters = {
			biome = {
				command = "biome",
				args = { "format", "--stdin-file-path", "$FILENAME" },
				stdin = true,
			},
		},
	},
	config = function(_, opts)
		local conform = require("conform")
		conform.setup(opts)
	end,
}
