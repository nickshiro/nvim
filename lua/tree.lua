local api = vim.api
local keymap = vim.keymap
local nvim_create_autocmd = vim.api.nvim_create_autocmd
local nvim_create_user_command = vim.api.nvim_create_user_command
local devicons = require("nvim-web-devicons")
local icon_namespace = api.nvim_create_namespace("filetree_icons")

local MIN_WIDTH = 28
local states = {}
local clipboard
local group = api.nvim_create_augroup("FileTree", { clear = true })
local git_styles = {
	ignored = { icon = "", highlight = "Comment", priority = 0 },
	untracked = { icon = "", highlight = "Added", priority = 1 },
	added = { icon = "✚", highlight = "Added", priority = 2 },
	modified = { icon = "", highlight = "Changed", priority = 3 },
	renamed = { icon = "󰁕", highlight = "Changed", priority = 4 },
	deleted = { icon = "✖", highlight = "Removed", priority = 5 },
	conflict = { icon = "", highlight = "DiagnosticError", priority = 6 },
}

local function parse_git(output, repo)
	local statuses = {}
	local records = vim.split(output, "\0", { plain = true, trimempty = true })

	local function merge(path, kind, staged)
		local previous = statuses[path]
		if previous and git_styles[previous.kind].priority > git_styles[kind].priority then
			kind = previous.kind
		end

		statuses[path] = { kind = kind, staged = staged or (previous and previous.staged) }
	end

	local i = 1
	while i <= #records do
		local record = records[i]
		local code = record:sub(1, 2)
		local relative = record:sub(4):gsub("/$", "")
		local path = vim.fs.joinpath(repo, relative)
		local kind

		if code == "!!" then
			kind = "ignored"
		elseif code == "??" then
			kind = "untracked"
		elseif code:find("U", 1, true) or code == "AA" or code == "DD" then
			kind = "conflict"
		elseif code:find("D", 1, true) then
			kind = "deleted"
		elseif code:find("R", 1, true) or code:find("C", 1, true) then
			kind = "renamed"
		elseif code:find("M", 1, true) or code:find("T", 1, true) then
			kind = "modified"
		else
			kind = "added"
		end
		local staged = kind ~= "conflict" and code:sub(1, 1):match("[AMDRCT]") ~= nil
		merge(path, kind, staged)
		-- propagate changes to collapsed parents, but keep ignored status local.
		if kind ~= "ignored" then
			for parent in vim.fs.parents(path) do
				if parent == repo then
					break
				end
				merge(parent, kind, staged)
			end
		end
		-- with -z, a rename/copy has a second record containing the old name.
		if code:find("[RC]") then
			i = i + 1
		end
		i = i + 1
	end

	return statuses
end

local function fit_tree(win)
	local width = 1
	for _, line in ipairs(api.nvim_buf_get_lines(api.nvim_win_get_buf(win), 0, -1, false)) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end

	local textoff = vim.fn.getwininfo(win)[1].textoff
	api.nvim_set_option_value("winfixwidth", true, { win = win, scope = "local" })
	api.nvim_win_set_width(win, math.max(MIN_WIDTH, width + textoff + 1))
end

local function tree_window(state)
	if state and api.nvim_tabpage_is_valid(state.tab) then
		for _, win in ipairs(api.nvim_tabpage_list_wins(state.tab)) do
			if api.nvim_win_get_buf(win) == state.buf then
				return win
			end
		end
	end
end

local function render(state)
	local win = tree_window(state)
	if not win then
		return
	end

	local buf = state.buf
	local view = api.nvim_win_call(win, vim.fn.winsaveview)
	local row = api.nvim_win_get_cursor(win)[1]
	local selected = state.entries[row] and state.entries[row].path or state.selected
	local lines = {}
	local highlights = {}
	local function highlight(col, text, group)
		highlights[#highlights + 1] = { row = #lines, col = col, length = #text, group = group }
	end

	local diagnostics = {}
	for _, diagnostic in ipairs(vim.diagnostic.get()) do
		local path = api.nvim_buf_get_name(diagnostic.bufnr)
		if path ~= "" and vim.fs.relpath(state.root, path) then
			for parent in vim.fs.parents(path) do
				diagnostics[parent] = math.min(diagnostics[parent] or diagnostic.severity, diagnostic.severity)
				if parent == state.root then
					break
				end
			end

			diagnostics[path] = math.min(diagnostics[path] or diagnostic.severity, diagnostic.severity)
		end
	end

	state.entries = {}

	local function scan(path, prefix, ignored)
		local children = {}
		for name, kind, err in vim.fs.dir(path, { err = true }) do
			if err then
				vim.notify(err, vim.log.levels.WARN)
				return
			end

			local child = vim.fs.joinpath(path, name)
			if kind == "link" then
				local stat = vim.uv.fs_stat(child)
				kind = stat and stat.type or kind
			end

			children[#children + 1] = { name = name, path = child, directory = kind == "directory" }
		end

		table.sort(children, function(a, b)
			if a.directory ~= b.directory then
				return a.directory
			end

			return a.name < b.name
		end)

		for i, entry in ipairs(children) do
			local last = i == #children
			local indent = path == state.root and "" or prefix .. (last and "└─ " or "├─ ")
			if indent ~= "" then
				highlight(0, indent, "NonText")
			end

			local marker
			if entry.directory then
				local arrow = state.expanded[entry.path] and "" or ""
				marker = arrow .. (state.expanded[entry.path] and "  " or "  ")
				highlight(#indent, arrow, "NonText")
			else
				local icon, icon_highlight = devicons.get_icon(entry.name, nil, { default = true })
				marker = icon .. " "
				highlight(#indent, icon, icon_highlight)
			end

			-- filenames containing newlines on single buffer line
			local name = entry.name:gsub("\n", "\\n")
			local line = indent .. marker .. name

			local status = state.git[entry.path] or ignored
			if status then
				local style = git_styles[status.kind]
				local show_badge = not entry.directory or not state.expanded[entry.path]

				highlight(#indent + #marker, name, style.highlight)

				if show_badge and style.icon ~= "" then
					highlight(#line + 1, style.icon, style.highlight)
					line = line .. " " .. style.icon
				end

				if show_badge and status.staged then
					highlight(#line + 1, "", "Added")
					line = line .. " "
				end
			end

			local diagnostic = diagnostics[entry.path]
			if diagnostic and (not entry.directory or not state.expanded[entry.path]) then
				local icon = vim.diagnostic.config().signs.text[diagnostic]
				local group = "Diagnostic" .. vim.diagnostic.severity[diagnostic]:lower():gsub("^%l", string.upper)
				highlight(#line + 1, icon, group)
				line = line .. " " .. icon
			end

			lines[#lines + 1] = line
			state.entries[#state.entries + 1] = entry
			if entry.directory and state.expanded[entry.path] then
				local child_prefix = path == state.root and "" or prefix .. (last and "   " or "│  ")
				scan(entry.path, child_prefix, status and status.kind == "ignored" and status)
			end
		end
	end

	scan(state.root, "", state.git[state.root] and state.git[state.root].kind == "ignored" and state.git[state.root])
	vim.bo[buf].modifiable = true
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	api.nvim_buf_clear_namespace(buf, icon_namespace, 0, -1)

	for _, highlight in ipairs(highlights) do
		api.nvim_buf_set_extmark(buf, icon_namespace, highlight.row, highlight.col, {
			end_col = highlight.col + highlight.length,
			hl_group = highlight.group,
		})
	end

	for i, entry in ipairs(state.entries) do
		if entry.path == selected then
			row = i
			break
		end
	end

	view.lnum = math.max(1, math.min(row, #lines))
	api.nvim_win_call(win, function()
		vim.fn.winrestview(view)
	end)

	fit_tree(win)
end

local function refresh(state)
	render(state)
	state.request = state.request + 1
	local request, buf = state.request, state.buf
	local function valid()
		return request == state.request and buf == state.buf and api.nvim_buf_is_valid(buf)
	end
	if vim.fn.executable("git") == 0 then
		return
	end

	vim.system(
		{ "git", "-C", state.root, "rev-parse", "--show-toplevel" },
		{},
		vim.schedule_wrap(function(result)
			if not valid() then
				return
			end

			if result.code ~= 0 then
				if next(state.git) then
					state.git = {}
					render(state)
				end
				return
			end

			local repo = result.stdout:gsub("\n$", "")

			vim.system(
				{
					"git",
					"--no-optional-locks",
					"-C",
					state.root,
					"status",
					"--porcelain=v1",
					"-z",
					"--ignored=matching",
					"--untracked-files=all",
					"--",
					".",
				},
				{},
				vim.schedule_wrap(function(status)
					if valid() then
						local statuses = status.code == 0 and parse_git(status.stdout, repo) or {}
						if not vim.deep_equal(state.git, statuses) then
							state.git = statuses
							render(state)
						end
					end
				end)
			)
		end)
	)
end

local function target_window(state)
	local function usable(win)
		return win
			and api.nvim_win_is_valid(win)
			and api.nvim_win_get_tabpage(win) == state.tab
			and api.nvim_win_get_config(win).relative == ""
			and vim.bo[api.nvim_win_get_buf(win)].buftype == ""
	end

	if usable(state.target) then
		return state.target
	end
	for _, win in ipairs(api.nvim_tabpage_list_wins(state.tab)) do
		if usable(win) then
			state.target = win
			return win
		end
	end

	local tree = tree_window(state)
	vim.cmd("botright vnew")
	state.target = api.nvim_get_current_win()
	api.nvim_set_option_value("winfixwidth", vim.go.winfixwidth, { win = state.target, scope = "local" })
	api.nvim_set_option_value("list", vim.go.list, { win = state.target, scope = "local" })
	api.nvim_set_option_value("number", vim.go.number, { win = state.target, scope = "local" })
	api.nvim_set_option_value("relativenumber", vim.go.relativenumber, { win = state.target, scope = "local" })
	api.nvim_set_option_value("signcolumn", vim.go.signcolumn, { win = state.target, scope = "local" })
	fit_tree(tree)

	return state.target
end

local function open_entry(state)
	local win = api.nvim_get_current_win()
	local entry = state.entries[api.nvim_win_get_cursor(win)[1]]
	if not entry then
		return
	end
	if entry.directory then
		state.expanded[entry.path] = not state.expanded[entry.path]
		render(state)
		return
	end

	api.nvim_set_current_win(target_window(state))

	local ok, err = pcall(vim.cmd, "edit " .. vim.fn.fnameescape(entry.path))
	if not ok then
		vim.notify(err, vim.log.levels.ERROR)
	end

	fit_tree(win)
end

local function edit_entry(state, action)
	local entry = state.entries[api.nvim_win_get_cursor(0)[1]]
	if action ~= "add" and not entry then
		return
	end

	local ok, err = pcall(function()
		if action == "delete" then
			assert(vim.fn.delete(entry.path, entry.directory and "rf" or "") == 0, "Cannot delete: " .. entry.path)
			return
		end

		local name = vim.fn.input(action == "rename" and "rename: " or "add: ", action == "rename" and entry.name or "")
		if name == "" then
			return
		end

		local base = entry and (action == "add" and entry.directory and entry.path or vim.fs.dirname(entry.path))
			or state.root

		local path =
			vim.fs.normalize(vim.fs.joinpath(name:sub(1, 1) == "/" and state.root or base, (name:gsub("^/+", ""))))
		if action == "rename" then
			if path == entry.path then
				return
			end

			assert(not vim.uv.fs_lstat(path), "Already exists: " .. path)
			vim.fn.mkdir(vim.fs.dirname(path), "p")
			assert(vim.uv.fs_rename(entry.path, path))

			for _, buf in ipairs(api.nvim_list_bufs()) do
				local old = api.nvim_buf_get_name(buf)
				if old == entry.path or old:sub(1, #entry.path + 1) == entry.path .. "/" then
					api.nvim_buf_set_name(buf, path .. old:sub(#entry.path + 1))
				end
			end
		elseif name:sub(-1) == "/" then
			vim.fn.mkdir(path, "p")
		else
			vim.fn.mkdir(vim.fs.dirname(path), "p")
			local fd = assert(vim.uv.fs_open(path, "wx", 420))
			vim.uv.fs_close(fd)
		end

		for parent in vim.fs.parents(path) do
			if parent == state.root then
				break
			end
			state.expanded[parent] = true
		end

		state.entries, state.selected = {}, path
	end)
	if not ok then
		vim.notify(err, vim.log.levels.ERROR)
	end

	refresh(state)
end

local function copy_path(source, destination)
	local stat = assert(vim.uv.fs_lstat(source), "Cannot read: " .. source)

	if stat.type == "directory" then
		assert(vim.uv.fs_mkdir(destination, stat.mode), "Cannot create directory: " .. destination)
		for name in vim.fs.dir(source) do
			copy_path(vim.fs.joinpath(source, name), vim.fs.joinpath(destination, name))
		end
	elseif stat.type == "link" then
		local target = assert(vim.uv.fs_readlink(source), "Cannot read link: " .. source)
		assert(vim.uv.fs_symlink(target, destination), "Cannot create link: " .. destination)
	else
		assert(vim.uv.fs_copyfile(source, destination), "Cannot copy: " .. source)
		vim.uv.fs_chmod(destination, stat.mode)
	end
end

local function copy_entry(state, visual)
	local first = api.nvim_win_get_cursor(0)[1]
	local last = visual and vim.fn.line("v") or first
	first, last = math.min(first, last), math.max(first, last)
	local paths, selected = {}, {}
	for row = first, last do
		local entry = state.entries[row]
		if entry then
			local covered = false
			for parent in vim.fs.parents(entry.path) do
				if selected[parent] then
					covered = true
					break
				end
			end
			if not covered then
				paths[#paths + 1] = entry.path
				selected[entry.path] = true
			end
		end
	end
	if visual then
		api.nvim_feedkeys(api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
	end
	if #paths == 0 then
		return
	end

	clipboard = paths
	vim.notify(#paths == 1 and ("copied: " .. paths[1]) or ("copied: " .. #paths .. " items"))
end

local function paste_entry(state)
	if not clipboard then
		vim.notify("file tree clipboard is empty", vim.log.levels.WARN)
		return
	end

	local entry = state.entries[api.nvim_win_get_cursor(0)[1]]
	local destination_dir = entry and (entry.directory and entry.path or vim.fs.dirname(entry.path)) or state.root
	local pending, destinations, pasted = {}, {}, {}
	local ok, err = pcall(function()
		-- Resolve all names before copying so cancellation leaves the destination untouched.
		for _, source in ipairs(clipboard) do
			local name = vim.fs.basename(source)
			local destination = vim.fs.joinpath(destination_dir, name)
			if vim.uv.fs_lstat(destination) or destinations[destination] then
				name = vim.fn.input("rename: ", name)
				if name == "" then
					return
				end
				assert(name ~= "." and name ~= ".." and not name:find("/", 1, true), "A new name must not contain a path")
				destination = vim.fs.joinpath(destination_dir, name)
			end
			assert(vim.uv.fs_lstat(source), "source no longer exists: " .. source)
			assert(not vim.uv.fs_lstat(destination) and not destinations[destination], "already exists: " .. destination)
			assert(not vim.startswith(destination, source .. "/"), "cannot copy a directory into itself: " .. source)
			pending[#pending + 1] = { source = source, destination = destination }
			destinations[destination] = true
		end
		for _, item in ipairs(pending) do
			copy_path(item.source, item.destination)
			pasted[#pasted + 1] = item.destination
		end
	end)

	if #pasted > 0 then
		state.entries, state.selected = {}, pasted[#pasted]
	end
	refresh(state)
	if not ok then
		vim.notify(err .. (#pasted > 0 and ("\nAlready pasted: " .. #pasted .. " items") or ""), vim.log.levels.ERROR)
		return
	end
	if #pasted > 0 then
		vim.notify(#pasted == 1 and ("pasted: " .. pasted[1]) or ("pasted: " .. #pasted .. " items"))
	end
end

local function close_tree()
	local win = tree_window(states[api.nvim_get_current_tabpage()])
	if not win then
		return
	end

	if vim.fn.winnr("$") == 1 then
		api.nvim_win_set_buf(win, api.nvim_create_buf(true, false))
		api.nvim_set_option_value("winfixwidth", vim.go.winfixwidth, { win = win, scope = "local" })
		api.nvim_set_option_value("list", vim.go.list, { win = win, scope = "local" })
		api.nvim_set_option_value("number", vim.go.number, { win = win, scope = "local" })
		api.nvim_set_option_value("relativenumber", vim.go.relativenumber, { win = win, scope = "local" })
		api.nvim_set_option_value("signcolumn", vim.go.signcolumn, { win = win, scope = "local" })
	else
		api.nvim_win_close(win, true)
	end
end

local function open_tree(single)
	local tab, root = api.nvim_get_current_tabpage(), vim.fn.getcwd()

	local state = states[tab]
	if not state or state.root ~= root then
		state = { tab = tab, root = root, expanded = {}, git = {}, request = 0 }
		states[tab] = state
	end

	local win = tree_window(state)
	if win then
		api.nvim_set_current_win(win)
		return
	end

	state.target = api.nvim_get_current_win()
	state.entries = nil
	state.buf = api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "wipe"
	vim.bo[state.buf].filetype = "filetree"

	if not single then
		vim.cmd("topleft vsplit")
	end

	win = api.nvim_get_current_win()
	api.nvim_win_set_buf(win, state.buf)
	api.nvim_set_option_value("list", false, { win = win, scope = "local" })
	api.nvim_set_option_value("number", false, { win = win, scope = "local" })
	api.nvim_set_option_value("relativenumber", false, { win = win, scope = "local" })
	api.nvim_set_option_value("signcolumn", "no", { win = win, scope = "local" })
	state.entries = {}

	keymap.set("n", "<CR>", function()
		open_entry(state)
	end, { buffer = state.buf })
	keymap.set("n", "q", close_tree, { buffer = state.buf })
	keymap.set("n", "r", function()
		edit_entry(state, "rename")
	end, { buffer = state.buf })
	keymap.set("n", "a", function()
		edit_entry(state, "add")
	end, { buffer = state.buf })
	keymap.set("n", "d", function()
		edit_entry(state, "delete")
	end, { buffer = state.buf })
	keymap.set("n", "y", function()
		copy_entry(state)
	end, { buffer = state.buf })
	keymap.set("x", "y", function()
		copy_entry(state, true)
	end, { buffer = state.buf, desc = "Copy selected files and directories" })
	keymap.set("n", "p", function()
		paste_entry(state)
	end, { buffer = state.buf })

	refresh(state)

	if state.view then
		state.view.lnum = api.nvim_win_get_cursor(win)[1]
		vim.fn.winrestview(state.view)
	end

	nvim_create_autocmd("BufWinLeave", {
		group = group,
		buffer = state.buf,
		callback = function()
			local tree = tree_window(state)
			if tree then
				state.view = api.nvim_win_call(tree, vim.fn.winsaveview)
				local entry = state.entries[state.view.lnum]
				state.selected = entry and entry.path
			end
		end,
	})
end

local function reveal_tree()
	local tab = api.nvim_get_current_tabpage()
	local state = states[tab]
	local buf = api.nvim_get_current_buf()
	if state and buf == state.buf and state.target and api.nvim_win_is_valid(state.target) then
		buf = api.nvim_win_get_buf(state.target)
	end

	local path = api.nvim_buf_get_name(buf)
	open_tree()
	state = states[tab]
	if path == "" or not vim.uv.fs_stat(path) then
		return
	end

	local changed_root = not vim.fs.relpath(state.root, path)
	if changed_root then
		state.root = vim.fs.dirname(path)
		state.expanded, state.git = {}, {}
	end
	for parent in vim.fs.parents(path) do
		if parent == state.root then
			break
		end
		state.expanded[parent] = true
	end
	state.entries, state.selected = {}, path
	if changed_root then
		refresh(state)
	else
		render(state)
	end
end

nvim_create_user_command("TreeOpen", function()
	open_tree()
end, {})
nvim_create_user_command("TreeReveal", reveal_tree, {})
nvim_create_user_command("TreeTarget", function()
	local state = states[api.nvim_get_current_tabpage()]
	if state then
		api.nvim_set_current_win(target_window(state))
	end
end, {})
nvim_create_user_command("TreeClose", close_tree, {})
nvim_create_user_command("TreeToggle", function()
	if tree_window(states[api.nvim_get_current_tabpage()]) then
		close_tree()
	else
		open_tree()
	end
end, {})

nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	group = group,
	callback = function(event)
		local state = states[api.nvim_get_current_tabpage()]
		if not state or not state.entries then
			return
		end

		local win = api.nvim_get_current_win()
		if vim.bo.buftype == "" and api.nvim_win_get_config(win).relative == "" then
			state.target = win
		elseif event.event == "BufEnter" and event.buf == state.buf then
			refresh(state)
		end
	end,
})

nvim_create_autocmd({ "BufWritePost", "FocusGained", "TermLeave" }, {
	group = group,
	callback = function()
		for _, state in pairs(states) do
			if tree_window(state) then
				refresh(state)
			end
		end
	end,
})

nvim_create_autocmd("DiagnosticChanged", {
	group = group,
	callback = function()
		vim.schedule(function()
			for _, state in pairs(states) do
				render(state)
			end
		end)
	end,
})

nvim_create_autocmd("DirChanged", {
	group = group,
	callback = function()
		local state = states[api.nvim_get_current_tabpage()]
		local root = vim.v.event.cwd
		if not state or state.root == root or vim.v.event.changed_window then
			return
		end

		state.root = root
		state.expanded, state.git, state.entries = {}, {}, {}
		state.selected, state.view = nil, nil

		local win = tree_window(state)
		if win then
			api.nvim_win_set_cursor(win, { 1, 0 })
			refresh(state)
		end
	end,
})

nvim_create_autocmd("TabClosed", {
	group = group,
	callback = function()
		for tab in pairs(states) do
			if not api.nvim_tabpage_is_valid(tab) then
				states[tab] = nil
			end
		end
	end,
})

nvim_create_autocmd("VimEnter", {
	group = group,
	once = true,
	callback = function()
		local buf = api.nvim_get_current_buf()
		local path = api.nvim_buf_get_name(buf)
		if vim.bo[buf].modified or (path ~= "" and vim.fn.isdirectory(path) == 0) then
			return
		end
		if path ~= "" then
			vim.cmd("lcd " .. vim.fn.fnameescape(path))
		end

		open_tree(true)

		api.nvim_buf_delete(buf, {})
	end,
})
