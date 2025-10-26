local operators = {
	biome = function(path)
		return { "biome", "format", path, "--write" }
	end,
	stylua = function(path)
		return { "stylua", path }
	end,
}

local associations = {
	lua = operators.stylua,
	html = operators.biome,
	css = operators.biome,
	json = operators.biome,
	yaml = operators.biome,
	javascript = operators.biome,
	javascriptreact = operators.biome,
	typescript = operators.biome,
	typescriptreact = operators.biome,
}

local function slice(tbl, i, j)
	local res = {}
	if i < 1 then
		i = 1
	end
	if not j or j > #tbl then
		j = #tbl
	end
	for k = i, j do
		table.insert(res, tbl[k])
	end
	return res
end

local function common_prefix_len(a, b)
	if not a or not b then
		return 0
	end
	local min_len = math.min(#a, #b)
	for i = 1, min_len do
		if string.byte(a, i) ~= string.byte(b, i) then
			return i - 1
		end
	end
	return min_len
end

local function common_suffix_len(a, b)
	if not a or not b then
		return 0
	end
	local a_len, b_len = #a, #b
	local min_len = math.min(a_len, b_len)
	for i = 0, min_len - 1 do
		if string.byte(a, a_len - i) ~= string.byte(b, b_len - i) then
			return i
		end
	end
	return min_len
end

local function buf_line_ending(bufnr)
	local ff = vim.bo[bufnr].fileformat
	if ff == "dos" then
		return "\r\n"
	end
	return "\n"
end

local function create_text_edit(
	original_lines,
	replacement,
	is_insert,
	is_replace,
	orig_line_start,
	orig_line_end,
	line_ending
)
	local start_line, end_line = orig_line_start - 1, orig_line_end - 1
	local start_char, end_char = 0, 0

	if is_replace then
		start_char = common_prefix_len(original_lines[orig_line_start] or "", replacement[1] or "")
		if start_char > 0 then
			replacement[1] = (replacement[1] or ""):sub(start_char + 1)
		end

		if original_lines[orig_line_end] then
			local last_line = replacement[#replacement] or ""
			local suffix = common_suffix_len(original_lines[orig_line_end], last_line)
			if orig_line_end == orig_line_start then
				suffix = math.min(suffix, (#original_lines[orig_line_end] or 0) - start_char)
			end
			end_char = (#original_lines[orig_line_end] or 0) - suffix
			if suffix > 0 then
				replacement[#replacement] = last_line:sub(1, #last_line - suffix)
			end
		end
	end

	if is_insert and start_line < #original_lines - 1 then
		table.insert(replacement, "")
	end

	local new_text = table.concat(replacement, line_ending)

	return {
		newText = new_text,
		range = {
			start = { line = start_line, character = start_char },
			["end"] = { line = end_line, character = end_char },
		},
	}
end

local function compute_text_edits(bufnr, original_lines, new_lines)
	if bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return {}
	end

	table.insert(original_lines, "")
	table.insert(new_lines, "")

	local original_text = table.concat(original_lines, "\n")
	local new_text = table.concat(new_lines, "\n")

	table.remove(original_lines)
	table.remove(new_lines)

	local indices = vim.text.diff(original_text, new_text, { result_type = "indices", algorithm = "histogram" })
	if not indices or vim.tbl_isempty(indices) then
		return {}
	end

	local text_edits = {}
	local line_ending = buf_line_ending(bufnr)

	for _, idx in ipairs(indices) do
		local orig_line_start, orig_line_count, new_line_start, new_line_count = unpack(idx)
		local is_insert = orig_line_count == 0
		local is_delete = new_line_count == 0
		local is_replace = (not is_insert) and not is_delete

		local orig_line_end = orig_line_start + orig_line_count
		local new_line_end = new_line_start + new_line_count

		if is_replace then
			orig_line_end = orig_line_end - 1
		end

		if is_insert then
			orig_line_start = orig_line_start + 1
			orig_line_end = orig_line_end + 1
		end

		local replacement = slice(new_lines, new_line_start, new_line_end - 1)

		local edit = create_text_edit(
			original_lines,
			replacement,
			is_insert,
			is_replace,
			orig_line_start,
			orig_line_end,
			line_ending
		)
		table.insert(text_edits, edit)
	end

	return text_edits
end

local function apply_text_edits(bufnr, text_edits)
	if bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	if not text_edits or vim.tbl_isempty(text_edits) then
		return false
	end

	vim.lsp.util.apply_text_edits(text_edits, bufnr, "utf-8")
	return true
end

local function soft_reload(path, bufnr)
	if bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local ok, new_lines = pcall(vim.fn.readfile, path)
	if not ok then
		vim.notify("Failed to read file: " .. path, vim.log.levels.ERROR)
		return
	end
	local old_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	if vim.deep_equal(old_lines, new_lines) then
		return
	end

	local edits = compute_text_edits(bufnr, old_lines, new_lines)
	if not edits or vim.tbl_isempty(edits) then
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
		return
	end

	apply_text_edits(bufnr, edits)
end

local function format()
	local bufnr = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(bufnr)
	local filetype = vim.bo.filetype
	local association = associations[filetype]

	if not association then
		vim.notify("No formatter associated with filetype: " .. filetype, vim.log.levels.WARN)
		return
	end

	local cmd = association(path)

	vim.fn.jobstart(cmd, {
		on_exit = function(_, code)
			if code == 0 then
				vim.schedule(function()
					soft_reload(path, bufnr)
				end)
			else
				vim.notify("Fmt failed with " .. code, vim.log.levels.ERROR)
			end
		end,
	})
end

vim.api.nvim_create_user_command("Fmt", format, {})
