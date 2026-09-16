local function exe(command)
	return function()
		vim.api.nvim_command(command)
	end
end

local opts = { noremap = true, silent = true }

-- File
vim.keymap.set("", "<leader>w", exe("w"))
vim.keymap.set("", "<leader>fm", function()
	vim.lsp.buf.format()
end, opts)

-- LSP
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

-- Clipboard
vim.keymap.set("", "<leader>y", '"+y')
vim.keymap.set("", "<leader>d", '"+d')
vim.keymap.set("", "<leader>D", '"+D')
vim.keymap.set("n", "<leader>Y", ":%y+<CR>")

-- Telescope
local function telescope(picker, options)
	return function()
		if vim.bo.filetype == "filetree" then
			vim.cmd.TreeTarget()
		end
		require("telescope.builtin")[picker](options)
	end
end

vim.keymap.set("n", "<leader>ff", telescope("find_files"), opts)
vim.keymap.set("n", "<leader>fg", telescope("live_grep"), opts)
vim.keymap.set("n", "<leader>*", telescope("grep_string"), opts)
vim.keymap.set("n", "<leader>r", telescope("resume"), opts)
vim.keymap.set("n", "<leader>xx", telescope("diagnostics"), opts)
vim.keymap.set("n", "<leader>xw", telescope("diagnostics", { bufnr = 0 }), opts)

-- Treesitter motion
vim.keymap.set("n", "]f", function()
	require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer")
end, opts)
vim.keymap.set("n", "]F", function()
	require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer")
end, opts)
vim.keymap.set("n", "[f", function()
	require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer")
end, opts)
vim.keymap.set("n", "[F", function()
	require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer")
end, opts)

-- Tree
vim.keymap.set("n", "<leader>e", function()
	vim.cmd.TreeToggle()
end, opts)
vim.keymap.set("n", "<leader>o", function()
	vim.cmd.TreeOpen()
end, opts)
vim.keymap.set("n", "<leader>O", function()
	vim.cmd.TreeReveal()
end, opts)

-- Splits
vim.keymap.set("n", "<leader>\\", vim.cmd.split, opts)
vim.keymap.set("n", "<leader>|", vim.cmd.vsplit, opts)
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Tabs
vim.keymap.set("n", "<leader>tn", vim.cmd.tabnew, opts)
vim.keymap.set("n", "<leader>tc", vim.cmd.tabclose, opts)
vim.keymap.set("n", "]t", vim.cmd.tabnext, opts)
vim.keymap.set("n", "[t", vim.cmd.tabprevious, opts)

-- Pack management
vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, {})
vim.api.nvim_create_user_command("PackDelete", function(o)
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

-- npm
-- TODO: EXPERIMENTAL

local function npm_complete(line, cursor)
	line = line:sub(1, cursor):gsub("^%s*%S+", "npm")
	local words = vim.split(line, "%s+", {
		trimempty = false,
	})

	words[1] = "npm"

	local result = vim.system({
		"npm",
		"completion",
		"--",
		unpack(words),
	}, {
		cwd = vim.fn.getcwd(),
		env = {
			COMP_LINE = line,
			COMP_POINT = tostring(vim.str_utfindex(line, "utf-16")),
			COMP_CWORD = tostring(#words - 1),
		},
	}):wait(2000)

	if result.code ~= 0 then
		return {}
	end

	return vim.split(result.stdout or "", "\n", {
		trimempty = true,
	})
end

vim.api.nvim_create_user_command("Npm", function(opts)
	local cwd = vim.fn.getcwd()
	vim.cmd("botright 12new")
	vim.bo.bufhidden = "hide"
	local job = vim.fn.jobstart({ "npm", unpack(opts.fargs) }, {
		cwd = cwd,
		term = true,
	})
	if job <= 0 then
		vim.notify("Failed to start npm", vim.log.levels.ERROR)
		return
	end
	vim.cmd.startinsert()
end, {
	nargs = "*",

	complete = function(_, cmd_line, cursor_pos)
		return npm_complete(cmd_line, cursor_pos)
	end,
})

vim.cmd.cabbrev({
	"<expr>",
	"npm",
	[[getcmdtype() == ':' && getcmdline() =~# '^npm\%(\s\|$\)' ? 'Npm' : 'npm']],
})
