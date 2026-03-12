vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tutor_mode_plugin = 0
vim.g.loaded_2html_plugin = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.fillchars:append({ eob = " " })

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

vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.encoding = "utf-8"
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.mouse = "a"
vim.opt.mousefocus = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.smarttab = true
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "skiprtp" }
vim.opt.list = true
vim.opt.listchars = { tab = "> ", space = "·" }
