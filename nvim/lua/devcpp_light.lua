-- DevC++ Classic Plus theme for Neovim
-- background white, text blue/black, red operators
-- Works correctly with Tree-sitter & LSP (no resourcing needed)

local M = {}

M.setup = function()
  vim.opt.termguicolors = true
  vim.o.background = "light"

  ------------------------------------------------------------------
  -- BASIC UI
  ------------------------------------------------------------------
  vim.api.nvim_set_hl(0, "Normal",        { fg = "#000000", bg = "#FFFFFF" })
  vim.api.nvim_set_hl(0, "LineNr",        { fg = "#888888" })
  vim.api.nvim_set_hl(0, "CursorLineNr",  { fg = "#00008B", bold = true })
  vim.api.nvim_set_hl(0, "CursorLine",    { bg = "#C0FFFF" })

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

  vim.api.nvim_set_hl(0, "Cursor",        { fg = "#FFFFFF", bg = "#000000" })
  vim.api.nvim_set_hl(0, "CursorIM",      { fg = "#FFFFFF", bg = "#000000" })
  vim.api.nvim_set_hl(0, "TermCursor",    { fg = "#FFFFFF", bg = "#000000" })
  vim.api.nvim_set_hl(0, "TermCursorNC",  { fg = "#FFFFFF", bg = "#000000" })

  ------------------------------------------------------------------
  -- BASE SYNTAX (non Tree-sitter)
  ------------------------------------------------------------------
  vim.api.nvim_set_hl(0, "Comment",   { fg = "#008FFF", italic = true })
  vim.api.nvim_set_hl(0, "Number",    { fg = "#800080" })
  vim.api.nvim_set_hl(0, "String",    { fg = "#0000FF" })
  vim.api.nvim_set_hl(0, "Constant",  { fg = "#008080" })
  vim.api.nvim_set_hl(0, "Function",  { fg = "#000000" })
  vim.api.nvim_set_hl(0, "PreProc",   { fg = "#008000" })

  vim.api.nvim_set_hl(0, "Keyword",   { fg = "#000000", bold = true })
  vim.api.nvim_set_hl(0, "Type",      { fg = "#000000", bold = true })
  vim.api.nvim_set_hl(0, "Identifier",{ fg = "#000000" })

  ------------------------------------------------------------------
  -- FUNCTION TO REAPPLY SYMBOL COLORS (IMPORTANT)
  ------------------------------------------------------------------
  local function apply_devcpp_symbols()
    -- Classic DevC++ red symbols
    vim.api.nvim_set_hl(0, "Operator",  { fg = "#FF0000" })
    vim.api.nvim_set_hl(0, "Delimiter", { fg = "#FF0000" })

    -- Tree-sitter
    vim.api.nvim_set_hl(0, "@operator", { fg = "#FF0000", force = true })
    vim.api.nvim_set_hl(0, "@symbol",   { fg = "#FF0000", force = true })

    vim.api.nvim_set_hl(0, "@punctuation.bracket",   { fg = "#FF0000", force = true })
    vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = "#FF0000", force = true })
  end

  ------------------------------------------------------------------
  -- TREE-SITTER / LSP GROUPS
  ------------------------------------------------------------------
  vim.api.nvim_set_hl(0, "@comment",   { fg = "#008FFF", italic = true })
  vim.api.nvim_set_hl(0, "@string",    { fg = "#0000FF" })
  vim.api.nvim_set_hl(0, "@number",    { fg = "#800080" })

  vim.api.nvim_set_hl(0, "@function",  { fg = "#000000" })
  vim.api.nvim_set_hl(0, "@method",    { fg = "#000000" })

  vim.api.nvim_set_hl(0, "@keyword",   { fg = "#000000", bold = true })
  vim.api.nvim_set_hl(0, "@type",      { fg = "#000000", bold = true })
  vim.api.nvim_set_hl(0, "@type.builtin",   { fg = "#000000", bold = true })
  vim.api.nvim_set_hl(0, "@type.qualifier", { fg = "#000000", bold = true })

  vim.api.nvim_set_hl(0, "@preproc", { fg = "#008000" })

  ------------------------------------------------------------------
  -- AUTOCMDS (THIS FIXES YOUR ISSUE)
  ------------------------------------------------------------------
  vim.api.nvim_create_autocmd({ "ColorScheme", "FileType" }, {
    callback = apply_devcpp_symbols,
  })

  -- Apply once immediately
  apply_devcpp_symbols()
end

return M












-- -- DevC++ Classic Plus theme for Neovim
-- -- background white, text blue, Consolas-like look
--
-- local M = {}
--
-- M.setup = function()
--   -- vim.cmd("highlight clear")
--   vim.o.background = "light"
--
--   -- Basic
--   vim.api.nvim_set_hl(0, "Normal", { fg="#000000", bg="#ffffff" })
--   vim.api.nvim_set_hl(0, "LineNr",       { fg="#888888" })
--   vim.api.nvim_set_hl(0, "CursorLineNr", { fg="#00008B", bold=true })
--   vim.api.nvim_set_hl(0, "CursorLine", { bg = "#C0FFFF" })
--
--   -- Visual selection: DevC++ style (dark bg, white text)
--   vim.api.nvim_set_hl(0, "Visual", {
--     bg = "#000080",
--     fg = "#ffffff"
--   })
--
--   -- Syntax highlighting
--   vim.api.nvim_set_hl(0, "Keyword",      { fg="#000000", bold=true })    -- blue keywords
--   vim.api.nvim_set_hl(0, "Type",         { fg="#000000", bold=true })    -- blue types
--   vim.api.nvim_set_hl(0, "Identifier",   { fg="#000000" })                -- dark blue variables
--   vim.api.nvim_set_hl(0, "@variable",    { fg="#000000" })
--   vim.api.nvim_set_hl(0, "@parameter",   { fg="#000000" })
--   vim.api.nvim_set_hl(0, "Comment",      { fg="#008FFF", italic=true })   -- lightblue comments
--   vim.api.nvim_set_hl(0, "Number",       { fg="#800080" })                -- purple numbers
--   vim.api.nvim_set_hl(0, "String",       { fg="#0000FF" })                -- blue strings
--   vim.api.nvim_set_hl(0, "Constant",     { fg="#008080" })                -- teal constants
--   vim.api.nvim_set_hl(0, "Function",     { fg="#000000" })                -- blue functions
--   vim.api.nvim_set_hl(0, "Symbol",       { fg="#FF0000"})                 -- red symbols
--   vim.api.nvim_set_hl(0, "Special",      { fg="#0000FF" })                -- blue operators etc.
--   vim.api.nvim_set_hl(0, "PreProc", { fg="#008000" })
--
--   -- Operators and punctuation in red (DevC++ Classic Plus)
--   vim.api.nvim_set_hl(0, "Operator", { fg = "#FF0000" })     -- < > = + -
--   vim.api.nvim_set_hl(0, "Delimiter", { fg = "#FF0000" })   -- , ; ()
--
--   -- Force a real block cursor (like DevC++)
--     vim.opt.guicursor = {
--       "n-v-c:block",
--       "i:ver25",
--       "r:hor20",
--     }
--
--     -- Cursor colors (REQUIRED for terminal Neovim)
--     vim.api.nvim_set_hl(0, "Cursor", { fg = "#ffffff", bg = "#000000" })
--     vim.api.nvim_set_hl(0, "CursorIM", { fg = "#ffffff", bg = "#000000" })
--     vim.api.nvim_set_hl(0, "TermCursor", { fg = "#ffffff", bg = "#000000" })
--     vim.api.nvim_set_hl(0, "TermCursorNC", { fg = "#ffffff", bg = "#000000" })
--     vim.opt.termguicolors = true
--     -- Tree-sitter / LSP support
--   vim.api.nvim_set_hl(0, "@function",    { fg="#000000" })
--   vim.api.nvim_set_hl(0, "@method",      { fg="#000000" })
--   vim.api.nvim_set_hl(0, "@type",        { fg="#000000" })
--   vim.api.nvim_set_hl(0, "@keyword",     { fg="#000000", bold=true })
--   vim.api.nvim_set_hl(0, "@string",      { fg="#0000FF" })
--   vim.api.nvim_set_hl(0, "@number",      { fg="#800080" })
--   vim.api.nvim_set_hl(0, "@comment",     { fg="#008FFF", italic=true })
--   vim.api.nvim_set_hl(0, "@operator",    { fg = "#FF0000" })
--   vim.api.nvim_set_hl(0, "@symbol",      { fg = "#FF0000" })
--   vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = "#FF0000" }) -- { } ( ) [ ]
--   vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = "#FF0000" }) -- , ;
--   vim.api.nvim_set_hl(0, "@preproc", { fg="#008000" })
--
--   -- Tree-sitter built-in types (void, char, float, double, etc.)
--   vim.api.nvim_set_hl(0, "@type.builtin", { fg="#000000", bold=true })
--
--   -- Some keywords like 'const', 'volatile' might be tagged as qualifier
--   vim.api.nvim_set_hl(0, "@type.qualifier", { fg="#000000", bold=true })
--
-- end
--
-- return M

