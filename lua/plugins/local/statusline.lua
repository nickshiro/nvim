local M = {}

local modes = {
	n = "N",
	i = "I",
	v = "V",
	V = "VL",
	[""] = "VB",
	c = "C",
	R = "R",
	t = "T",
}

local function mode()
	local mode = vim.fn.mode()
	return modes[mode] or mode
end

local function file()
	local path = vim.fn.expand("%:.")

	if vim.bo.filetype == "neo-tree" or path == "" then
		return ""
	end

	return path
end

local function branch()
	local ok, res = pcall(vim.fn.system, "git rev-parse --abbrev-ref HEAD")
	if ok then
		return " " .. vim.trim(res)
	end

	local ok, res = pcall(vim.fn.system, "git config --get init.defaultBranch")
	if ok then
		return " " .. vim.trim(res)
	end

	return ""
end

local function position()
	return vim.fn.line(".") .. ":" .. vim.fn.col(".")
end

function _G.statusline()
	return table.concat({ " ", mode(), " | ", file(), "%=", branch(), " | ", position(), " " })
end

function M.setup()
	vim.opt.showmode = false
	vim.o.laststatus = 3
	vim.o.statusline = "%!v:lua.statusline()"
end

return M
