require("plugins.autotag")
require("plugins.cmp")
require("plugins.colorizer")
require("plugins.devicons")
require("plugins.lsp")
require("plugins.ibl")
require("plugins.sessions")
require("plugins.statusline")
require("plugins.telescope")
require("plugins.tree")
require("plugins.treesitter")

vim.pack.add({
	"https://github.com/nickshiro/better-colorscheme.nvim",
	"https://github.com/nvim-mini/mini.trailspace",
	-- Themes
	"https://github.com/silentium-theme/silentium.nvim",
	"https://github.com/skewb1k/vague.nvim",
	"https://github.com/catppuccin/nvim",
	"https://github.com/sharpchen/Eva-Theme.nvim",
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/rose-pine/neovim",
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/Alligator/accent.vim",
}, { confirm = false })

require("mini.trailspace")

local silentium = require("silentium")
silentium.setup({ accent = silentium.accents.peach })
