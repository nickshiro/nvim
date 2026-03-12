local keymap = vim.keymap.set
local cmd = vim.api.nvim_create_user_command

local function exe(command)
	return function()
		vim.api.nvim_command(command)
	end
end

local opts = { noremap = true, silent = true }

-- File
keymap("", "<leader>w", exe("w"))
keymap("", "<leader>fm", function()
	vim.lsp.buf.format()
end, opts)

-- LSP
keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)

-- Clipboard
keymap("", "<leader>y", '"+y')
keymap("", "<leader>d", '"+d')
keymap("", "<leader>D", '"+D')
keymap("n", "<leader>Y", ":%y+<CR>")

-- Telescope
keymap("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, opts)
keymap("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, opts)
keymap("n", "<leader>*", function()
	require("telescope.builtin").grep_string()
end, opts)
keymap("n", "<leader>r", function()
	require("telescope.builtin").resume()
end, opts)
keymap("n", "<leader>xx", function()
	require("telescope.builtin").diagnostics()
end, opts)
keymap("n", "<leader>xw", function()
	require("telescope.builtin").diagnostics({ bufnr = 0 })
end, opts)

-- Treesitter motion
keymap("n", "]f", function()
	require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer")
end, opts)
keymap("n", "]F", function()
	require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer")
end, opts)
keymap("n", "[f", function()
	require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer")
end, opts)
keymap("n", "[F", function()
	require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer")
end, opts)

-- Neo-Tree
keymap("n", "<leader>e", function()
	require("neo-tree.command").execute({ toggle = true })
end, opts)

keymap("n", "<leader>o", function()
	require("neo-tree.command").execute({ action = "focus" })
end, opts)

-- Splits
keymap("n", "<leader>\\", vim.cmd.split, opts)
keymap("n", "<leader>|", vim.cmd.vsplit, opts)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Pack management
cmd("PackUpdate", function()
	vim.pack.update()
end, {})
cmd("PackDelete", function(o)
	vim.pack.del({ o.args })
end, {
	nargs = 1,
	complete = function(arglead)
		return vim.iter(vim.pack.get())
			:map(function(p)
				return p.spec.name
			end)
			:filter(function(name)
				return name:find(arglead, 1, true) == 1
			end)
			:totable()
	end,
})
