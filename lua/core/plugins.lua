require("plugins.autotag")
require("plugins.cmp")
require("plugins.colorizer")
require("plugins.devicons")
require("plugins.lsp")
require("plugins.ibl")
require("plugins.neocord")
require("plugins.sessions")
require("plugins.statusline")
require("plugins.telescope")
require("plugins.tree")
require("plugins.treesitter")

vim.pack.add({
	"https://github.com/nvim-mini/mini.trailspace",
	-- Themes
	"https://github.com/nickshiro/arc.nvim",
	"https://github.com/catppuccin/nvim",
	"https://github.com/sharpchen/Eva-Theme.nvim",
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/rose-pine/neovim",
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/vague2k/vague.nvim",
	"https://github.com/olivercederborg/poimandres.nvim",
	"https://github.com/sam4llis/nvim-tundra",
	"https://github.com/nickshiro/better-colorscheme.nvim",
	"file:///home/nick/w/elixir.nvim",
}, { confirm = false })

vim.cmd.packadd("elixir.nvim")
require("mini.trailspace")
