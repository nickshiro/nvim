vim.opt.showtabline = 0

local devicons = require("nvim-web-devicons")

local function get_icon(bufname)
	local fname = vim.fn.fnamemodify(bufname, ":t")
	return devicons.get_icon(fname, vim.fn.fnamemodify(bufname, ":e"), { default = true })
end

local hidden_ft = { ["neo-tree"] = true }

local function get_tab_buf(tabnr)
	local buflist = vim.fn.tabpagebuflist(tabnr)

	for _, buf in ipairs(buflist) do
		local ft = vim.fn.getbufvar(buf, "&filetype")
		if not hidden_ft[ft] and ft ~= "" then
			return buf
		end
	end

	return buflist[vim.fn.tabpagewinnr(tabnr)]
end

function _G.MyTabline()
	local parts = {}
	local current_tab = vim.fn.tabpagenr()

	for i = 1, vim.fn.tabpagenr("$") do
		local bufnr = get_tab_buf(i)
		local bufname = vim.fn.bufname(bufnr)

		local name = bufname ~= "" and vim.fn.fnamemodify(bufname, ":~:.") or "[No Name]"
		local modified = vim.fn.getbufvar(bufnr, "&modified") == 1 and " ●" or ""

		local hl = i == current_tab and "%#TabLineSel#" or "%#TabLine#"

		parts[i] = hl .. " " .. i .. ":" .. get_icon(bufname) .. " " .. name .. modified .. " "
	end

	return table.concat(parts) .. "%#TabLineFill#"
end

local function update_winbar()
	local tab_count = vim.fn.tabpagenr("$")
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)

		local is_floating = vim.api.nvim_win_get_config(win).relative ~= ""
		local is_hidden = hidden_ft[vim.bo[buf].filetype] == true

		local value = (is_floating or is_hidden or tab_count == 1) and "" or "%!v:lua.MyTabline()"

		if vim.api.nvim_get_option_value("winbar", { win = win }) ~= value then
			vim.api.nvim_set_option_value("winbar", value, { win = win })
		end
	end
end
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TabEnter", "TabNewEntered", "WinEnter" }, {
	callback = function()
		vim.schedule(update_winbar)
	end,
})
