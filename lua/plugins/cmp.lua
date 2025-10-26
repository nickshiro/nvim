vim.pack.add({
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/saadparwaiz1/cmp_luasnip",
	"https://github.com/hrsh7th/cmp-nvim-lua",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-buffer",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/windwp/nvim-autopairs",
}, { confirm = false })

require("luasnip").setup({ history = true, updateevents = "TextChanged,TextChangedI" })

local cmp = require("cmp")

cmp.setup({
	completion = { completeopt = "menu,menuone" },

	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},

	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),

	sources = cmp.config.sources({
		{ name = "nvim_lsp", priority = "100" },
		{ name = "luasnip", priority = "80" },
		{ name = "buffer", priority = "60" },
		{ name = "nvim_lua", priority = "70" },
		{ name = "path", priority = "90" },
		{ name = "emmet_language_server", priority = "0" },
	}),

	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(_, vim_item)
			local icons = {
				Method = "󰆧",
				Function = "󰡱",
				Constructor = "",
				Field = "󰜢",
				Variable = "󰫧",
				Class = "󰠱",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "󰑭",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌆",
				Snippet = "",
				Color = "󰏘",
				File = "",
				Reference = "󰈇",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰏿",
				Struct = "󰙅",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "",
				Text = "",
			}
			vim_item.kind = icons[vim_item.kind] or ""
			return vim_item
		end,
	},
})

-- Autopairs
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
