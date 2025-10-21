return {
    "lukas-reineke/indent-blankline.nvim",
    name = "ibl",
    main = "ibl",
    opts = {
        indent = { char = "│" },
        scope = {
            enabled = true,
            show_exact_scope = false,
            show_start = false,
            show_end = false
        },
        exclude = {
            filetypes = {
                "dashboard",
                "lazy",
                "help",
                "terminal",
                "TelescopePrompt",
            },
            buftypes = {
                "terminal",
                "nofile",
                "quickfix",
                "prompt",
            },
        },
    },
}
