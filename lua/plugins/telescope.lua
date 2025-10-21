return {
    "nvim-telescope/telescope.nvim",
    name = "telescope",
    lazy = false,
    dependencies = {
        { "nvim-lua/plenary.nvim",                   name = "plenary" },
        { "nvim-telescope/telescope-ui-select.nvim", name = "telescope-ui" },
    },
    config = function()
        local telescope = require("telescope")
        local themes = require("telescope.themes")

        telescope.setup({
            defaults = {
                file_ignore_patterns = {
                    ".git/",
                    "node_modules/",
                    "*.pyc",
                    "__pycache__/",
                    ".zig-cache/",
                },
            },
            pickers = {
                find_files = {
                    find_command = { "rg", "--files", "--hidden", "--glob", "!.git" },
                },
                colorscheme = { enable_preview = true },
            },
            extensions = {
                ["ui-select"] = themes.get_dropdown(),
            },
        })

        telescope.load_extension("ui-select");

        local function git(fn)
            return function()
                vim.fn.system("git rev-parse --is-inside-work-tree")
                if vim.v.shell_error == 0 then
                    fn()
                else
                    vim.notify("Not a git repository", vim.log.levels.WARN)
                end
            end
        end

        -- FILE
        vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
        vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
        vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
        vim.keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Keymaps" })
        vim.keymap.set("n", "<leader>fc", "<cmd>Telescope colorscheme<cr>", { desc = "Colorscheme" })
        vim.keymap.set("n", "<leader>*", "<cmd>Telescope grep_string<cr>", { desc = "Word under cursor" })
        vim.keymap.set("n", "<leader>r", "<cmd>Telescope resume<cr>", { desc = "Resume last search" })
        vim.keymap.set("n", "<leader>t", "<cmd>TodoTelescope<cr>", { desc = "Todo list" })

        -- GIT
        vim.keymap.set("n", "<leader>gb", git(function() vim.cmd("Telescope git_branches") end),
            { desc = "Git branches" })
        vim.keymap.set("n", "<leader>gc", git(function() vim.cmd("Telescope git_commits") end), { desc = "Git commits" })
        vim.keymap.set("n", "<leader>gs", git(function() vim.cmd("Telescope git_status") end), { desc = "Git status" })

        -- DIAGNOSTIC
        vim.keymap.set("n", "<leader>xx", "<cmd>Telescope diagnostics<cr>", { desc = "Diagnostic" })
        vim.keymap.set("n", "<leader>xw", function()
            require("telescope.builtin").diagnostics({ bufnr = 0 })
        end, { desc = "Current buffer diagnostic" })
    end,
}
