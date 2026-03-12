vim.pack.add({ "https://github.com/lukas-reineke/indent-blankline.nvim" }, { confirm = false })

require("ibl").setup({
	indent = { char = "|" },
	scope = {
		enabled = true,
		show_exact_scope = false,
		show_start = false,
		show_end = false,
	},
	exclude = {
		filetypes = {
			"dashboard",
			"lazy",
			"help",
			"terminal",
			"neo-tree",
			"TelescopePrompt",
		},
		buftypes = {
			"nofile",
			"quickfix",
			"prompt",
		},
	},
})
