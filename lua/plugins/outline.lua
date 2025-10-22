vim.pack.add("https://github.com/hedyhli/outline.nvim", { confirm = false })
require("outline").setup({})

local map = vim.keymap.set
map("n", "<leader>E", "<cmd>Outline<CR>", { desc = "Toggle outline" })
map("n", "<leader>O", "<cmd>OutlineFocus<CR>", { desc = "Focus outline" })
