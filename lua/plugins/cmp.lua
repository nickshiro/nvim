return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        {
            "L3MON4D3/LuaSnip",
            name = "luasnip",
            dependencies = {
                "rafamadriz/friendly-snippets",
            },
            opts = {
                history = true,
                updateevents = "TextChanged,TextChangedI",
            },
            config = function(_, opts)
                require("luasnip").config.set_config(opts)
            end,
        },
        { "saadparwaiz1/cmp_luasnip", name = "cmp-luasnip" },
        { "hrsh7th/cmp-nvim-lua",     name = "cmp-nvim-lua" },
        { "hrsh7th/cmp-nvim-lsp",     name = "cmp-nvim-lsp" },
        { "hrsh7th/cmp-buffer",       name = "cmp-buffer" },
        { "hrsh7th/cmp-path",         name = "cmp-path" },
    },

    config = function()
        local cmp = require("cmp")

        cmp.setup({
            completion = { completeopt = "menu,menuone" },

            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },

            mapping = {
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.close(),
                ["<CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Insert,
                    select = true,
                }),

                ["<C-y>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif require("luasnip").jumpable(-1) then
                        require("luasnip").jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            },

            sources = cmp.config.sources({
                { name = "nvim_lsp",              priority = "100" },
                { name = "luasnip",               priority = "80" },
                { name = "buffer",                priority = "60" },
                { name = "nvim_lua",              priority = "70" },
                { name = "path",                  priority = "90" },
                { name = "emmet_language_server", priority = "0" }
            }),

            perfomance = {
                max_view_entries = 15,
            },

            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(_, vim_item)
                    local icons = {
                        Method = "󰆧",
                        Function = "󰡱",
                        Constructor = "",
                        Field = "󰜢",
                        Variable = "󰫧",
                        Class = "󰠱",
                        Interface = "",
                        Module = "",
                        Property = "󰜢",
                        Unit = "󰑭",
                        Value = "󰎠",
                        Enum = "",
                        Keyword = "󰌆",
                        Snippet = "",
                        Color = "󰏘",
                        File = "",
                        Reference = "󰈇",
                        Folder = "󰉋",
                        EnumMember = "",
                        Constant = "󰏿",
                        Struct = "󰙅",
                        Event = "",
                        Operator = "󰆕",
                        TypeParameter = "",
                        Text = "",
                    }
                    vim_item.kind = icons[vim_item.kind] or ""
                    return vim_item
                end,
            },
        })
    end,
}
