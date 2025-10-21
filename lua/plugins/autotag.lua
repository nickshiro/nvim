return {
    "windwp/nvim-ts-autotag",
    name = "autotag",
    event = "InsertEnter",
    dependencies = {
        { "nvim-treesitter/nvim-treesitter", name = "treesitter" },
    },
    config = function()
        local autotag = require "nvim-ts-autotag"

        autotag.setup({
            opts = {
                enable_close = true,
                enable_rename = true,
                enable_close_on_slash = true,
            },
            filetypes = {
                "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact",
                "tsx", "jsx", "markdown"
            },
            skip_tags = { "br", "img", "Image", "hr", "input", "meta", "link" },
        })

        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
                underline = true,
                virtual_text = {
                    spacing = 5,
                    severity_limit = "Warning",
                },
                update_in_insert = false,
            }
        )
    end,
}
