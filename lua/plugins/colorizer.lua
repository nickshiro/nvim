return {
    "catgoose/nvim-colorizer.lua",
    name = "colorizer",
    ft = { "css", "scss", "html", "javascriptreact", "typescriptreact", "vue", "svelte", "php" },
    config = function()
        require("colorizer").setup({
            filetypes = { "*" },
            user_default_options = {
                tailwind = true,
                names = false,
            },
        })
    end,
}
