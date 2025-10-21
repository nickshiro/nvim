return {
    "hedyhli/outline.nvim",
    name = "outline",
    lazy = true,
    cmd = { "Outline", "OutlineOpen", "OutlineFocus" },
    opts = function(_, opts)
        local map = vim.keymap.set

        map("n", "<leader>E", "<cmd>Outline<CR>", { desc = "Toggle outline" })
        map("n", "<leader>O", "<cmd>OutlineFocus<CR>", { desc = "Focus outline" })

        return opts
    end,
}
