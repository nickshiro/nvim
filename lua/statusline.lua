local nvim_create_autocmd = vim.api.nvim_create_autocmd

local modes = {
	n = "N",
	i = "I",
	v = "V",
	V = "VL",
	["\22"] = "VB",
	c = "C",
	R = "R",
	t = "T",
}

local function mode()
	return modes[vim.fn.mode()] or "?"
end

local function escape(text)
	return (text:gsub("%%", "%%%%"))
end

local function file()
	local ft = vim.bo.filetype
	if ft == "filetree" or ft == "nvim-pack" then
		return ""
	end

	local path = vim.fn.expand("%:.")
	if not path or path == "" then
		return ""
	end

	return escape(path)
end

local _branch_cache = {}
local function update_branch()
	local cwd = vim.fn.getcwd()
	if _branch_cache[cwd] then
		return
	end

	local entry = { text = "" }
	_branch_cache[cwd] = entry
	pcall(
		vim.system,
		{ "git", "symbolic-ref", "--quiet", "--short", "HEAD" },
		{ cwd = cwd, text = true },
		vim.schedule_wrap(function(result)
			if _branch_cache[cwd] ~= entry then
				return
			end
			local name = result.code == 0 and vim.trim(result.stdout or "") or ""
			entry.text = name ~= "" and ("󰘬 " .. escape(name)) or ""
			vim.cmd.redrawstatus()
		end)
	)
end

local group = vim.api.nvim_create_augroup("statusline", { clear = true })
nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	group = group,
	callback = update_branch,
})
nvim_create_autocmd(
	{ "DirChanged", "FocusGained", "ShellCmdPost", "ShellFilterPost", "TermLeave", "TermClose" },
	{
		group = group,
		callback = function()
			_branch_cache = {}
			update_branch()
		end,
	}
)

function _G.statusline()
	local entry = _branch_cache[vim.fn.getcwd()]
	return table.concat({
		" ",
		mode(),
		" │ ",
		file(),
		"%=",
		entry and entry.text or "",
		" │ %l:%c ",
	})
end

vim.opt.showmode = false
vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.statusline()"
update_branch()
