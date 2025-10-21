local opt = vim.opt
local wo = vim.wo
local g = vim.g

vim.g.mapleader = " "
vim.g.maplocalleader = " "

opt.fillchars:append({ eob = " " })

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.HINT] = "",
			[vim.diagnostic.severity.INFO] = "",
		},
	},
	virtual_text = {
		prefix = "●",
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

opt.wrap = false
opt.swapfile = false
opt.encoding = "utf-8"

opt.clipboard = "unnamedplus"

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.mouse = "a"
opt.mousefocus = true

opt.signcolumn = "yes"
opt.cursorline = true
opt.number = true
opt.relativenumber = true
wo.number = true
wo.relativenumber = true

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.cindent = true
opt.smarttab = true

g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
