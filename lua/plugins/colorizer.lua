vim.pack.add({ "https://github.com/catgoose/nvim-colorizer.lua" }, { confirm = false })

require("colorizer").setup({
	filetypes = { "*" },
	user_default_options = {
		tailwind = true,
		names = false,
	},
})
