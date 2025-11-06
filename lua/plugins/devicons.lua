vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons" }, { confirm = false })
local devicons = require("nvim-web-devicons")

local ts_icon, ts_color = devicons.get_icon_color("tsconfig.json", "tsconfig.json", { default = true })
local dc_icon, dc_color = devicons.get_icon_color("docker-compose.yml", "docker-compose.yml", { default = true })
local _, go_color = devicons.get_icon_color("go.go", "go", { default = true })
local _, gomod_color = devicons.get_icon_color("go.mod", "go.mod", { default = true })
local _, gosum_color = devicons.get_icon_color("go.sum", "go.sum", { default = true })
local _, license_color = devicons.get_icon_color("LICENSE", "LICENSE", { default = true })
local _, png_color = devicons.get_icon_color("png", "png", { default = true })
local _, json_color = devicons.get_icon_color("json", "json", { default = true })

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
	["docker-compose.dev.yml"] = {
		icon = dc_icon,
		color = dc_color,
		name = "DockerComposeDevYml",
	},
	["docker-compose.prod.yml"] = {
		icon = dc_icon,
		color = dc_color,
		name = "DockerComposeDevYml",
	},
    ["go"] = {
        icon = "",
        color = go_color,
        name = "Go"
    },
    ["go.mod"] = {
        icon = "",
        color = gomod_color,
        name = "GoMod"
    },
    ["go.sum"] = {
        icon = "",
        color = gosum_color,
        name = "GoSum"
    },
    ["license"] = {
        icon = "󰌆",
        color = license_color,
        name = "License"
    },
    ["golden"] = {
        icon = "󰂔",
        color = go_color,
        name = "GoldenTests",
    },
    ["png"] = {
        icon = "",
        color = png_color,
        name = "Png",
    },
    ["json"] = {
        icon = "",
        color = json_color,
        name = "Json"
    }
})

local _, unknown_color = devicons.get_icon_color("unknown", nil, { default = true })
devicons.set_default_icon("", unknown_color)
