vim.pack.add(
	{ "https://github.com/windwp/nvim-autopairs", "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ confirm = false }
)

local npairs = require("nvim-autopairs")

npairs.setup({
	check_ts = true,
	ts_config = {
		lua = { "string" },
		javascript = { "template_string" },
	},
	disable_filetype = { "TelescopePrompt", "spectre_panel" },
	disable_in_macro = true,
	disable_in_visualblock = false,
	ignored_next_char = "[%w%.]",
	enable_moveright = true,
	enable_afterquote = true,
	enable_check_bracket_line = true,
	enable_bracket_in_quote = true,
	fast_wrap = {
		map = "<M-e>",
		chars = { "{", "[", "(", '"', "'" },
		pattern = [=[[%'%"%>%]%)%}%,]]=],
		offset = 0,
		end_key = "$",
		keys = "qwertyuiopzxcvbnmasdfghjkl",
		check_comma = true,
		highlight = "Search",
		highlight_grey = "Comment",
	},
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
