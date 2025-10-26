local map = vim.keymap.set

local function exe(cmd)
	return function()
		vim.api.nvim_command(cmd)
	end
end

map("", "<leader>w", exe("w"))
map("", "<leader>f", exe("Fmt"))
map("", "<leader>y", '"+y')
map("", "<leader>d", '"+d')
map("", "<leader>D", '"+D')
