local map = vim.keymap.set
local telescope = require("telescope.builtin")
local ts_move = require("nvim-treesitter-textobjects.move")

local function exe(cmd)
	return function()
		vim.api.nvim_command(cmd)
	end
end

map("", "<leader>w", exe("w"))
map("", "<leader>fm", function()
	vim.lsp.buf.format()
end)
map("", "<leader>y", '"+y')
map("", "<leader>d", '"+d')
map("", "<leader>D", '"+D')
-- Telescope
map("n", "<leader>ff", telescope.find_files)
map("n", "<leader>fg", telescope.live_grep)
map("n", "<leader>fk", telescope.keymaps)
map("n", "<leader>*", telescope.grep_string)
map("n", "<leader>r", telescope.resume)
map("n", "<leader>xx", telescope.diagnostics)
map("n", "<leader>xw", function()
	telescope.diagnostics({ bufnr = 0 })
end)
-- Scope
map("n", "]f", function()
	ts_move.goto_next_start("@function.outer")
end)
map("n", "]F", function()
	ts_move.goto_next_end("@function.outer")
end)
map("n", "[f", function()
	ts_move.goto_previous_start("@function.outer")
end)
map("n", "[F", function()
	ts_move.goto_previous_end("@function.outer")
end)
-- Tree
map("n", "<leader>e", exe("Neotree toggle"))
map("n", "<leader>o", exe("Neotree focus"))

vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, {})
