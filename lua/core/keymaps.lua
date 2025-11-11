local map = vim.keymap.set
local telescope = require("telescope.builtin")

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

vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, {})
