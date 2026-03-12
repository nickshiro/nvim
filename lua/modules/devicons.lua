vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons" }, { confirm = false })
local devicons = require("nvim-web-devicons")

local function get_color(file, ext)
	local _, color = devicons.get_icon_color(file, ext, { default = true })
	return color
end

local function get_icon_color(file, ext)
	local icon, color = devicons.get_icon_color(file, ext, { default = true })
	return icon, color
end

local ts_icon, ts_color = get_icon_color("tsconfig.json", "tsconfig.json")
local dc_icon, dc_color = get_icon_color("docker-compose.yml", "docker-compose.yml")
local go_color = get_color("go.go", "go")
local gomod_color = get_color("go.mod", "go.mod")
local gosum_color = get_color("go.sum", "go.sum")
local license_color = get_color("LICENSE", "LICENSE")
local png_color = get_color("png", "png")
local json_color = get_color("json", "json")

local function make(icon, color, name)
	return { icon = icon, color = color, name = name }
end

local icons = {}

-- tsconfig variants
for _, variant in ipairs({ "app", "node", "base" }) do
	icons["tsconfig." .. variant .. ".json"] =
		make(ts_icon, ts_color, "TsConfig" .. variant:gsub("^%l", string.upper) .. "Json")
end

-- docker-compose variants
for _, env in ipairs({ "dev", "prod" }) do
	icons["docker-compose." .. env .. ".yml"] =
		make(dc_icon, dc_color, "DockerCompose" .. env:gsub("^%l", string.upper) .. "Yml")
end

-- Misc
icons["go"] = make("", go_color, "Go")
icons["go.mod"] = make("", gomod_color, "GoMod")
icons["go.sum"] = make("", gosum_color, "GoSum")
icons["license"] = make("󰌆", license_color, "License")
icons["png"] = make("", png_color, "Png")
icons["json"] = make("", json_color, "Json")
icons["golden"] = make("󰂔", go_color, "GoldenTests")
icons["architecture.md"] = make("", "#40FBA7", "ArchitectureMd")

devicons.set_icon(icons)

local _, unknown_color = devicons.get_icon_color("unknown", nil, { default = true })
devicons.set_default_icon("", unknown_color)
