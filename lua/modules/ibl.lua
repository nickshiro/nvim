-- inspired by https://github.com/lukas-reineke/indent-blankline.nvim

local group = vim.api.nvim_create_augroup("indent_guides", { clear = true })

local scope_types = {
	lua = "do_statement while_statement repeat_statement if_statement for_statement function_declaration function_definition",
	c = "preproc_function_def for_statement if_statement while_statement function_definition compound_statement struct_specifier",
	cpp = "class_specifier template_declaration body template_function template_method function_declarator lambda_expression catch_clause requires_expression",
	ecma = "statement_block function arrow_function function_declaration method_definition for_statement for_in_statement catch_clause",
	go = "func_literal function_declaration if_statement block expression_switch_statement for_statement method_declaration",
	rust = "block function_item closure_expression while_expression for_expression loop_expression if_expression match_expression match_arm expression_statement struct_item enum_item impl_item",
	bash = "function_definition",
	json = "object array",
	toml = "table table_array_element",
	yaml = "block_node",
	html = "element",
	elixir = "call stab_clause",
	heex = "component slot tag",
	nix = "let_expression rec_attrset_expression function_expression",
	query = "named_node anonymous_node grouping",
	git_config = "section",
}

scope_types.cpp = scope_types.c .. " " .. scope_types.cpp
scope_types.javascript = scope_types.ecma .. " jsx_element"
scope_types.tsx = scope_types.javascript
scope_types.typescript = scope_types.ecma
scope_types.json5 = scope_types.json
scope_types.jsonc = scope_types.json
scope_types.svelte = scope_types.html

for language, types in pairs(scope_types) do
	scope_types[language] = {}
	for name in types:gmatch("%S+") do
		scope_types[language][name] = true
	end
end

local excluded_filetypes = {
	dashboard = true,
	lazy = true,
	help = true,
	terminal = true,
	filetree = true,
	TelescopePrompt = true,
}
local excluded_buftypes = { nofile = true, quickfix = true, prompt = true, terminal = true }

local function set_highlights()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
	vim.api.nvim_set_hl(0, "IndentGuideActive", { fg = normal.fg })
end

local function scope(win, buf)
	local ok, parser = pcall(vim.treesitter.get_parser, buf)
	if not ok or not parser then
		return
	end

	local cursor = vim.api.nvim_win_get_cursor(win)
	local row, col = cursor[1] - 1, cursor[2]
	parser:parse({ row, row + 1 })
	local range = { row, 0, row, col }
	local language = parser:language_for_range(range)

	local types = scope_types[language:lang()]
	if not types then
		return
	end

	local node = language:named_node_for_range(range)
	while node and node:byte_length() > 0 do
		if types[node:type()] then
			local first, _, last = node:range()
			return first, last
		end
		node = node:parent()
	end
end

local matches = {}

local function update(win)
	if not vim.api.nvim_win_is_valid(win) then
		return
	end
	for _, id in ipairs(matches[win] or {}) do
		pcall(vim.fn.matchdelete, id, win)
	end
	matches[win] = {}
	local buf = vim.api.nvim_win_get_buf(win)
	if excluded_filetypes[vim.bo[buf].filetype] or excluded_buftypes[vim.bo[buf].buftype] then
		return
	end
	local first, last = scope(win, buf)
	if not first then
		return
	end

	vim.api.nvim_win_call(win, function()
		local opening = vim.api.nvim_buf_get_lines(buf, first, first + 1, false)[1] or ""
		local closing = vim.api.nvim_buf_get_lines(buf, last, last + 1, false)[1] or ""
		local column =
			math.min(vim.fn.strdisplaywidth(opening:match("^[ \t]*")), vim.fn.strdisplaywidth(closing:match("^[ \t]*")))
		local positions = {}
		local function flush()
			if #positions > 0 then
				matches[win][#matches[win] + 1] = vim.fn.matchaddpos("IndentGuideActive", positions, 200)
				positions = {}
			end
		end
		-- Only existing whitespace in the visible part of the scope is highlighted.
		for row = math.max(first + 1, vim.fn.line("w0") - 1), math.min(last, vim.fn.line("w$") - 1) do
			local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
			local whitespace = line:match("^[ \t]*")
			local current = 0
			for byte = 1, #whitespace do
				local following = whitespace:sub(byte, byte) == "\t" and vim.fn.strdisplaywidth(whitespace:sub(1, byte))
					or current + 1
				if current <= column and column < following then
					positions[#positions + 1] = { row + 1, byte, 1 }
					if #positions == 8 then
						flush()
					end
					break
				end
				current = following
			end
		end
		flush()
	end)
end

local pending = false
local function refresh()
	if pending then
		return
	end
	pending = true
	vim.schedule(function()
		pending = false
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			update(win)
		end
	end)
end

vim.api.nvim_create_autocmd({
	"CursorMoved",
	"CursorMovedI",
	"TextChanged",
	"TextChangedI",
	"TextChangedP",
	"BufWinEnter",
	"WinEnter",
	"WinScrolled",
	"WinResized",
	"FileType",
}, { group = group, callback = refresh })
vim.api.nvim_create_autocmd("OptionSet", {
	group = group,
	pattern = { "tabstop", "vartabstop", "list", "listchars" },
	callback = refresh,
})
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = function()
		set_highlights()
		refresh()
	end,
})
vim.api.nvim_create_autocmd("WinClosed", {
	group = group,
	callback = function(event)
		matches[tonumber(event.match)] = nil
	end,
})

set_highlights()
refresh()
