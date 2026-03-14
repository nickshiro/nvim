vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "skiprtp" }

local session_dir = vim.fn.stdpath("data") .. "/sessions"

local function ensure_dir()
	if vim.fn.isdirectory(session_dir) == 0 then
		vim.fn.mkdir(session_dir, "p")
	end
end

local function session_path()
	local cwd = vim.fn.getcwd()
	local name = vim.fn.sha256(cwd):sub(1, 16)
	return session_dir .. "/" .. name .. ".vim"
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		if vim.fn.argc() == 0 then
			local path = session_path()
			if vim.fn.filereadable(path) == 1 then
				vim.cmd("silent! source " .. vim.fn.fnameescape(path))

				local saved_win = vim.api.nvim_get_current_win()
				local saved_bufnr = vim.api.nvim_get_current_buf()

				vim.cmd("bufdo doautocmd BufRead")
				vim.cmd("doautocmd FileType")

				pcall(vim.api.nvim_set_current_win, saved_win)
				pcall(vim.api.nvim_set_current_buf, saved_bufnr)
			end
		end
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		ensure_dir()
		local path = session_path()
		vim.cmd("silent! mksession! " .. vim.fn.fnameescape(path))
	end,
})

vim.api.nvim_create_autocmd("DirChanged", {
	callback = function()
		ensure_dir()
	end,
})

vim.api.nvim_create_user_command("SessionDelete", function()
	vim.fn.delete(session_path())
end, {})
