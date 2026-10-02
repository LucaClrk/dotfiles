return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "json",
                "javascript",
                "typescript",
                "tsx",
                "go",
                "yaml",
                "html",
                "css",
                "python",
                "http",
                "prisma",
                "markdown",
                "markdown_inline",
                "svelte",
                "graphql",
                "bash",
                "lua",
                "vim",
                "dockerfile",
                "gitignore",
                "query",
                "vimdoc",
                "c",
                "java",
                "rust",
                "ron",
            })

            -- highlight + indent for every filetype that has a parser
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
                callback = function(args)
                    if pcall(vim.treesitter.start, args.buf) then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },

    -- js,ts,jsx,tsx auto close tags
    {
        "windwp/nvim-ts-autotag",
        ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
        opts = {
            opts = {
                enable_close = true,
                enable_rename = true,
                enable_close_on_slash = false,
            },
            per_filetype = {
                ["html"] = { enable_close = true },
                ["typescriptreact"] = { enable_close = true },
            },
        },
    },
}
