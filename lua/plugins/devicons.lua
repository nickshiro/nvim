vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons" }, { confirm = false })
local devicons = require("nvim-web-devicons")

local ts_icon, ts_color = devicons.get_icon_color("tsconfig.json", "tsconfig.json", { default = true })

devicons.set_icon({
	["tsconfig.app.json"] = {
		icon = ts_icon,
		color = ts_color,
		name = "TsConfigAppJson",
	},
	["tsconfig.node.json"] = {
		icon = ts_icon,
		color = ts_color,
		name = "TsConfigNodeJson",
	},
})
