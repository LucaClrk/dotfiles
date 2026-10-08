-- Installs + configures theme plugins (does not pick one).
-- All themes stay installed so the pickers (<leader>th, <leader>ths) can switch.
-- The active one is set in lua/config/colorscheme.lua.
return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "frappe", -- latte, frappe, macchiato, mocha
        },
    },
    -- gruvbox: matches the ghostty gruvbox theme (bg #282828, fg #ebdbb2)
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            italic = {
                strings = false,
                emphasis = false,
                comments = false,
                folds = false,
                operators = false,
            },
            contrast = "", -- "hard", "soft" or "" (medium, same as ghostty)
            overrides = {
                Pmenu = { bg = "" },
            },
            transparent_mode = true, -- let ghostty's #282828 show through
        },
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        opts = {
            variant = "main",
            dark_variant = "main",
            styles = {
                bold = true,
                italic = false,
                transparency = true,
            },
            highlight_groups = {
                ColorColumn = { bg = "#1C1C21" },
                Normal = { bg = "none" },
                Pmenu = { bg = "", fg = "#e0def4" },
                PmenuSel = { bg = "#4a465d", fg = "#f8f5f2" },
                PmenuSbar = { bg = "#191724" },
                PmenuThumb = { bg = "#9ccfd8" },
            },
            enable = {
                terminal = false,
                legacy_highlights = false,
                migrations = true,
            },
        },
    },
    {
        "rebelot/kanagawa.nvim",
        opts = {
            commentStyle = { italic = true },
            keywordStyle = { italic = false },
            statementStyle = { bold = true },
            transparent = true,
            colors = {
                theme = {
                    all = {
                        ui = {
                            bg_gutter = "none",
                            border = "rounded",
                        },
                    },
                },
            },
            overrides = function(colors)
                local theme = colors.theme
                return {
                    NormalFloat = { bg = "none" },
                    FloatBorder = { bg = "none" },
                    FloatTitle = { bg = "none" },
                    Pmenu = { fg = theme.ui.shade0, bg = "NONE", blend = vim.o.pumblend },
                    PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                    PmenuSbar = { bg = theme.ui.bg_m1 },
                    PmenuThumb = { bg = theme.ui.bg_p2 },
                    NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
                    LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
                    MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
                    TelescopeTitle = { fg = theme.ui.special, bold = true },
                    TelescopePromptBorder = { fg = theme.ui.special },
                    TelescopeResultsNormal = { fg = theme.ui.fg_dim },
                    TelescopeResultsBorder = { fg = theme.ui.special },
                    TelescopePreviewBorder = { fg = theme.ui.special },
                }
            end,
            theme = "wave",
            background = { dark = "wave" },
        },
    },
    {
        "craftzdog/solarized-osaka.nvim",
        opts = {
            transparent = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = false },
                sidebars = "dark",
                floats = "dark",
            },
            sidebars = { "qf", "help" },
            on_highlights = function(hl, c)
                hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg_dark }
                hl.TelescopeBorder = { bg = c.bg_dark, fg = c.bg_dark }
                hl.TelescopePromptNormal = { bg = c.bg_dark }
                hl.TelescopePromptBorder = { bg = c.bg_dark, fg = c.bg_dark }
                hl.TelescopePromptTitle = { bg = "#2d3149", fg = "#2C94DD" }
                hl.TelescopePreviewTitle = { bg = c.bg_dark, fg = c.bg_dark }
                hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.bg_dark }
            end,
        },
    },
    {
        "folke/tokyonight.nvim",
        name = "folkeTokyonight",
        main = "tokyonight",
        opts = {
            style = "night",
            transparent = true,
            styles = {
                comments = { italic = false },
                keywords = { italic = false },
                sidebars = "transparent",
                floats = "transparent",
            },
            on_colors = function(colors)
                colors.bg = colors.none
                colors.bg_dark = colors.none
                colors.bg_float = colors.none
                colors.bg_highlight = "#143652"
                colors.bg_popup = "#011423"
                colors.bg_search = "#0A64AC"
                colors.bg_sidebar = colors.none
                colors.bg_statusline = colors.none
                colors.bg_visual = "#275378"
                colors.border = "#547998"
                colors.fg = "#CBE0F0"
                colors.fg_dark = "#B4D0E9"
                colors.fg_float = "#CBE0F0"
                colors.fg_gutter = "#627E97"
                colors.fg_sidebar = "#B4D0E9"
            end,
        },
    },
}
