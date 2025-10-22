vim.pack.add({
	"https://github.com/nvim-neo-tree/neo-tree.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/MunifTanjim/nui.nvim",
}, { confirm = false })

require("neo-tree").setup({
	hide_root_node = true,
	sources = { "filesystem", "buffers", "git_status" },
	git_status = {
		enabled = true,
		align = "right",
	},
	filesystem = {
		follow_current_file = {
			enabled = true,
		},
		filtered_items = {
			visible = false,
			hide_dotfiles = false,
			hide_gitignored = false,
			never_show = {},
		},
	},
	window = {
		width = 28,
		auto_expand_width = true,
		mappings = {
			["/"] = "noop",
			["f"] = "noop",
			["F"] = "noop",
			["b"] = "rename_basename",
			["<space>"] = "none",
			["Y"] = {
				function(state)
					local node = state.tree:get_node()
					local path = node:get_id()
					vim.fn.setreg("+", path, "c")
				end,
				desc = "Copy Path to Clipboard",
			},
			["O"] = {
				function(state)
					require("lazy.util").open(state.tree:get_node().path, { system = true })
				end,
				desc = "Open with System Application",
			},
			["P"] = { "toggle_preview", config = { use_float = false } },
		},
	},
	default_component_configs = {
		indent = {
			indent_size = 1,
			with_markers = false,
			indent_marker = "│",
			last_indent_marker = "└",
			with_expanders = true,
			expander_collapsed = "",
			expander_expanded = "",
		},
		icon = {
			default = "",
			folder_closed = "",
			folder_open = "",
			folder_empty = "",
			folder_empty_open = "",
			highlight = "NeoTreeFileIcon",
		},
		git_status = {
			symbols = {
				added = "✚",
				deleted = "✖",
				modified = "",
				renamed = "󰁕",
				untracked = "", --"",
				ignored = "",
				unstaged = "", -- "󰏫",
				staged = "",
				conflict = "",
			},
		},
		file_size = {
			enabled = true,
			width = 12,
			required_width = 64,
		},
	},
	use_popups_for_input = false,
})
local map = vim.keymap.set

map("n", "<leader>e", "<CMD>Neotree toggle<CR>", { desc = "Toggle tree" })
map("n", "<leader>o", "<CMD>Neotree focus<CR>", { desc = "Focus tree" })
