return {
    "folke/todo-comments.nvim",
    name = "todo-comments",
    dependencies = {
        { "nvim-lua/plenary.nvim",         name = "plenary" },
        { "nvim-telescope/telescope.nvim", name = "telescope" },
    },
    opts = {
        signs = false,
        keywords = {
            FIX = { icon = " ", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
            TODO = { icon = " " },
            HACK = { icon = " " },
            WARN = { icon = " ", alt = { "WARNING", "XXX" } },
        },
    },
}
