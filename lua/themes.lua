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
