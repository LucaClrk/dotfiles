return {
    {
        "OXY2DEV/markview.nvim",
        lazy = false,
        opts = {
            latex = {
                enable = true,
                inlines = { enable = true },
                blocks = { enable = true },
            },
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
    },
}
