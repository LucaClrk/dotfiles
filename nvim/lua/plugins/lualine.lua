return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local lazy_status = require("lazy.status") -- pending plugin updates count

        local mode = {
            "mode",
            fmt = function(str)
                return " " .. str
            end,
        }

        local diff = {
            "diff",
            colored = true,
            symbols = { added = " ", modified = " ", removed = " " },
        }

        local filename = {
            "filename",
            file_status = true,
            path = 0,
        }

        require("lualine").setup({
            options = {
                theme = "auto", -- follows the active colorscheme (gruvbox)
                component_separators = { left = "|", right = "|" },
                section_separators = { left = "|", right = "" },
            },
            sections = {
                lualine_a = { mode },
                lualine_b = { { "branch", icon = "" } },
                lualine_c = { diff, filename },
                lualine_x = {
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = { fg = "#fe8019" },
                    },
                    { "filetype" },
                },
            },
        })
    end,
}
