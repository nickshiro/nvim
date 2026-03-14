vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons" }, { confirm = false })
local devicons = require("nvim-web-devicons")

local ext_icons = devicons.get_icons_by_extension()
local file_icons = devicons.get_icons_by_filename()

local ts_icon, ts_color = "", ext_icons["ts"].color
local js_icon, js_color = "", "#ffca28"
local dc_icon, dc_color = file_icons["docker-compose.yml"].icon, file_icons["docker-compose.yml"].color
local go_icon, go_color = "", ext_icons["go"].color
local gop_icon, gop_color = "", "#ec407a"
local license_icon, license_color = "󰌆", file_icons["license.md"].color
local scm_icon, scm_color = "󰘧", ext_icons["scm"].color
local vim_icon, vim_color = ext_icons["vim"].icon, ext_icons["vim"].color
local architecture_icon, architecture_color = "", "#40FBA7"
local sh_icon, sh_color = "", "#40FBA7"
local lock_icon, lock_color = "", ext_icons["lock"].color
local css_icon, css_color = "", "#7e57c2"
local readme_icon, readme_color = "󰋼", "#42a5f5"
local json_icon, json_color = "", ext_icons["json"].color
local md_icon, md_color = "", ext_icons["md"].color

devicons.setup({
	strict = true,
	default = true,
	color_icons = true,
	override_by_extension = {
		ts = { icon = ts_icon, color = ts_color, name = "Ts" },
		["d.ts"] = { icon = ts_icon, color = ts_color, name = "DTs" },
		js = { icon = js_icon, color = js_color, name = "Js" },
		mjs = { icon = js_icon, color = js_color, name = "MJs" },
		cjs = { icon = js_icon, color = js_color, name = "CJs" },
		scm = { icon = scm_icon, color = scm_color, name = "Scm" },
		go = { icon = go_icon, color = go_color, name = "Go" },
		sh = { icon = sh_icon, color = sh_color, name = "Sh" },
		lock = { icon = lock_icon, color = lock_color, name = "Lock" },
		css = { icon = css_icon, color = css_color, name = "Css" },
		json = { icon = json_icon, color = json_color, name = "Json" },
		md = { icon = md_icon, color = md_color, name = "Md" },
	},
	override_by_filename = {
		["tsconfig.app.json"] = { icon = ts_icon, color = ts_color, name = "TsConfigApp" },
		["tsconfig.node.json"] = { icon = ts_icon, color = ts_color, name = "TsConfigApp" },
		["tsconfig.base.json"] = { icon = ts_icon, color = ts_color, name = "TsConfigApp" },
		["docker-compose.dev.yml"] = { icon = dc_icon, color = dc_color, name = "DockerComposeYml" },
		["docker-compose.prod.yml"] = { icon = dc_icon, color = dc_color, name = "DockerComposeYml" },
		["go.mod"] = { icon = gop_icon, color = gop_color, name = "GoMod" },
		["go.sum"] = { icon = go_icon, color = go_color, name = "GoSum" },
		["LICENSE.md"] = { icon = license_icon, color = license_color, name = "License" },
		["LICENSE"] = { icon = license_icon, color = license_color, name = "License" },
		["LICENSE.txt"] = { icon = license_icon, color = license_color, name = "License" },
		["architecture.md"] = { icon = architecture_icon, color = architecture_color, name = "ArchitectureMd" },
		["README.md"] = { icon = readme_icon, color = readme_color, name = "ReadmeMd" },
		["nvim-pack-lock.json"] = { icon = vim_icon, color = vim_color, name = "NvimPackLock" },
	},
})
