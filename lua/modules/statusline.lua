local modes = {
	n = "N",
	i = "I",
	v = "V",
	V = "VL",
	[""] = "VB",
	c = "C",
	R = "R",
	t = "T",
}

local function mode()
	return modes[vim.fn.mode()] or "?"
end

local function file()
	local ft = vim.bo.filetype
	if ft == "neo-tree" or ft == "nvim-pack" then
		return ""
	end

	local path = vim.fn.expand("%:.")
	if not path or path == "" then
		return ""
	end

	return path
end

local _branch_cache = {}
local function branch()
	local cwd = vim.fn.getcwd()
	if _branch_cache[cwd] ~= nil then
		return _branch_cache[cwd]
	end

	local ok, out = pcall(vim.fn.system, "git rev-parse --abbrev-ref HEAD 2>/dev/null")
	out = ok and vim.trim(out) or ""

	local result
	if out ~= "" and out ~= "HEAD" then
		result = " " .. out
	else
		local dok, def = pcall(vim.fn.system, "git config --get init.defaultBranch 2>/dev/null")
		def = dok and vim.trim(def) or ""
		result = def ~= "" and (" " .. def) or ""
	end

	_branch_cache[cwd] = "󰘬" .. result
	return "󰘬" .. result
end

vim.api.nvim_create_autocmd({ "DirChanged", "FocusGained" }, {
	callback = function()
		_branch_cache = {}
	end,
})

function _G.statusline()
	return table.concat({
		" ",
		mode(),
		" │ ",
		file(),
		"%=",
		branch(),
		" │ %l:%c ",
	})
end

vim.opt.showmode = false
vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.statusline()"
