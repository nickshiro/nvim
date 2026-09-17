require("modules.cmp")
require("modules.devicons")
require("modules.discord")
require("modules.lsp")
require("modules.ibl")
require("modules.statusline")
require("modules.telescope")
require("modules.tree")
require("modules.treesitter")

vim.pack.add({
	"https://github.com/windwp/nvim-ts-autotag",
	"https://github.com/nvim-mini/mini.trailspace",
	"https://github.com/silentium-theme/silentium.nvim",
	"https://github.com/skewb1k/vague.nvim",
	"https://github.com/catppuccin/nvim",
}, { confirm = false })

local silentium = require("silentium")
silentium.setup({ accent = silentium.accents.peach })
vim.cmd.colorscheme("silentium")

require("nvim-ts-autotag").setup({
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = true,
	},
})

vim.opt.runtimepath:append("~/w/prlsp")
