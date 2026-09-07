local dir = vim.fn.stdpath("data") .. "/sessions"
local root = vim.fn.getcwd(-1, -1)
local path = dir .. "/" .. vim.fn.sha256(root):sub(1, 16) .. ".vim"
local group = vim.api.nvim_create_augroup("ProjectSessions", { clear = true })
local skip = vim.fn.argc() > 0 or vim.v.vim_did_enter == 1
local active, saved = false, nil

local function revision()
	local stat, err, code = vim.uv.fs_stat(path)
	if not stat and code ~= "ENOENT" then
		error(err)
	end

	return stat and { stat.size, stat.mtime, stat.ctime } or nil
end

local function report(ok, err)
	if not ok then
		vim.notify("Session: " .. tostring(err), vim.log.levels.ERROR)
	end
end

vim.api.nvim_create_autocmd("StdinReadPre", {
	group = group,
	once = true,
	callback = function()
		skip = true
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	once = true,
	nested = true,
	callback = function()
		if skip or vim.v.this_session ~= "" or #vim.api.nvim_list_uis() == 0 then
			return
		end

		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[buf].buflisted and (vim.bo[buf].modified or vim.api.nvim_buf_get_name(buf) ~= "") then
				return
			end
		end

		local ok, err = pcall(function()
			saved = revision()
			if saved then
				vim.cmd("source " .. vim.fn.fnameescape(path))
			end
		end)

		active = ok
		report(ok, err)
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = group,
	callback = function()
		if not active or (vim.v.this_session ~= "" and vim.v.this_session ~= path) then
			return
		end

		local temp = path .. "." .. vim.fn.getpid() .. ".tmp"
		local previous = vim.v.this_session

		local ok, err = pcall(function()
			assert(vim.deep_equal(saved, revision()), "changed by another process: " .. path)
			vim.fn.mkdir(dir, "p")
			vim.cmd("mksession! " .. vim.fn.fnameescape(temp))
			assert(vim.deep_equal(saved, revision()), "changed by another process: " .. path)

			if saved then
				assert(vim.fn.writefile(vim.fn.readfile(path, "b"), path .. ".bak", "b") == 0, "backup failed")
			end

			assert(vim.uv.fs_rename(temp, path))
		end)

		vim.v.this_session = ok and path or previous
		vim.fn.delete(temp)

		report(ok, err)
	end,
})

vim.api.nvim_create_user_command("SessionDelete", function()
	active = false
	local ok, err = pcall(function()
		if revision() then
			assert(vim.fn.delete(path) == 0, "cannot delete " .. path)
		end

		if vim.v.this_session == path then
			vim.v.this_session = ""
		end
	end)

	report(ok, err)
end, { desc = "Delete this session and disable autosaving until restart" })
