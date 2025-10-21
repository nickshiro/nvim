return {
	"nvim-tree/nvim-web-devicons",
	name = "devicons",
	config = function()
		local devicons = require("nvim-web-devicons")

		local icon, hl_group_name = devicons.get_icon("tsconfig.json", "json", { default = false })
		local hl = vim.api.nvim_get_hl_by_name(hl_group_name, true)
		local color = string.format("#%06x", hl.foreground or 0xffffff)

		devicons.set_icon({
			["tsconfig.app.json"] = {
				icon = icon,
				color = color,
				name = hl_group_name,
			},
			["tsconfig.node.json"] = {
				icon = icon,
				color = color,
				name = hl_group_name,
			},
		})
	end,
}
