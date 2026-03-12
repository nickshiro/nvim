local modes = {
	n = "-N-",
	i = "-I-",
	v = "-V-",
	V = "VL",
	[""] = "VB",
	c = "-C-",
	R = "-R-",
	t = "-T-",
}

local function mode()
	local m = vim.fn.mode()
	return modes[m] or m
end

local function file()
	local path = vim.fn.expand("%:.")

	if vim.bo.filetype == "neo-tree" or vim.bo.filetype == "nvim-pack" or path == "" then
		return ""
	end

	return path
end

local _branch_cache
local function branch()
	if _branch_cache ~= nil then
		return _branch_cache
	end

	local ok, res = pcall(vim.fn.system, "git rev-parse --abbrev-ref HEAD 2>/dev/null")
	res = ok and vim.trim(res) or ""

	if res ~= "" and res ~= "HEAD" then
		_branch_cache = " " .. res
	else
		local bok, bres = pcall(vim.fn.system, "git config --get init.defaultBranch 2>/dev/null")
		bres = bok and vim.trim(bres) or ""
		_branch_cache = bres ~= "" and (" " .. bres) or ""
	end

	return _branch_cache
end

vim.api.nvim_create_autocmd({ "DirChanged", "BufEnter", "FocusGained" }, {
	callback = function()
		_branch_cache = nil
	end,
})

function _G.statusline()
	return table.concat({ " ", mode(), " | ", file(), "%=", "", branch(), " | ", "%l:%c", " " })
end

vim.opt.showmode = false
vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.statusline()"
