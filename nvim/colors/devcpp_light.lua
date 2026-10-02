-- DevC++ Classic Plus theme for Neovim: `:colorscheme devcpp_light`
-- background white, text blue/black, red operators

vim.o.background = "light"
vim.cmd("highlight clear")
vim.g.colors_name = "devcpp_light"

vim.opt.termguicolors = true
vim.opt.colorcolumn = "" -- Turns off vertical line

------------------------------------------------------------------
-- BASIC UI
------------------------------------------------------------------
vim.api.nvim_set_hl(0, "Normal", { fg = "#000000", bg = "#FFFFFF" })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#888888" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#00008B", bold = true })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#C0FFFF" })

vim.api.nvim_set_hl(0, "Visual", {
    fg = "#FFFFFF",
    bg = "#000080",
})

------------------------------------------------------------------
-- CURSOR (DevC++ block cursor)
------------------------------------------------------------------
vim.opt.guicursor = {
    "n-v-c:block",
    "i:ver25",
    "r:hor20",
}

vim.api.nvim_set_hl(0, "Cursor", { fg = "#FFFFFF", bg = "#000000" })
vim.api.nvim_set_hl(0, "CursorIM", { fg = "#FFFFFF", bg = "#000000" })
vim.api.nvim_set_hl(0, "TermCursor", { fg = "#FFFFFF", bg = "#000000" })
vim.api.nvim_set_hl(0, "TermCursorNC", { fg = "#FFFFFF", bg = "#000000" })

------------------------------------------------------------------
-- BASE SYNTAX (non Tree-sitter)
------------------------------------------------------------------
vim.api.nvim_set_hl(0, "Comment", { fg = "#008FFF", italic = true })
vim.api.nvim_set_hl(0, "Number", { fg = "#800080" })
vim.api.nvim_set_hl(0, "String", { fg = "#0000FF" })
vim.api.nvim_set_hl(0, "Constant", { fg = "#008080" })
vim.api.nvim_set_hl(0, "Function", { fg = "#000000" })
vim.api.nvim_set_hl(0, "PreProc", { fg = "#008000" })

vim.api.nvim_set_hl(0, "Keyword", { fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "Type", { fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "Identifier", { fg = "#000000" })

------------------------------------------------------------------
-- FUNCTION TO REAPPLY SYMBOL COLORS (IMPORTANT)
------------------------------------------------------------------
local function apply_devcpp_symbols()
    -- Classic DevC++ red symbols
    vim.api.nvim_set_hl(0, "Operator", { fg = "#FF0000" })
    vim.api.nvim_set_hl(0, "Delimiter", { fg = "#FF0000" })

    -- Tree-sitter
    vim.api.nvim_set_hl(0, "@operator", { fg = "#FF0000", force = true })
    vim.api.nvim_set_hl(0, "@symbol", { fg = "#FF0000", force = true })

    vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = "#FF0000", force = true })
    vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = "#FF0000", force = true })
end

------------------------------------------------------------------
-- TREE-SITTER / LSP GROUPS
------------------------------------------------------------------
vim.api.nvim_set_hl(0, "@comment", { fg = "#008FFF", italic = true })
vim.api.nvim_set_hl(0, "@string", { fg = "#0000FF" })
vim.api.nvim_set_hl(0, "@number", { fg = "#800080" })

vim.api.nvim_set_hl(0, "@function", { fg = "#000000" })
vim.api.nvim_set_hl(0, "@method", { fg = "#000000" })

vim.api.nvim_set_hl(0, "@keyword", { fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "@type", { fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "@type.builtin", { fg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "@type.qualifier", { fg = "#000000", bold = true })

vim.api.nvim_set_hl(0, "@preproc", { fg = "#008000" })

------------------------------------------------------------------
-- AUTOCMDS
------------------------------------------------------------------
-- reapply while this theme is active; a no-op once you switch to another one
vim.api.nvim_create_autocmd({ "ColorScheme", "FileType" }, {
    group = vim.api.nvim_create_augroup("devcpp_light", { clear = true }),
    callback = function()
        if vim.g.colors_name == "devcpp_light" then
            apply_devcpp_symbols()
        end
    end,
})

-- Apply once immediately
apply_devcpp_symbols()
