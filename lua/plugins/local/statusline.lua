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
	local ok, res = pcall(vim.fn.system, "git rev-parse --abbrev-ref HEAD 2>/dev/null")
	if ok then
		res = vim.trim(res)
		if res ~= "" and res ~= "HEAD" then
			return " " .. res
		end
	end

	local branchOk, branchRes = pcall(vim.fn.system, "git config --get init.defaultBranch 2>/dev/null")
	if branchOk then
		branchRes = vim.trim(branchRes)
		if branchRes ~= "" then
			return " " .. branchRes
		end
	end

	return ""
end

local function position()
	return vim.fn.line(".") .. ":" .. vim.fn.col(".")
end

function _G.statusline()
	return table.concat({ " ", mode(), " | ", file(), "%=", branch(), " | ", position(), " " })
end

vim.opt.showmode = false
vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.statusline()"
