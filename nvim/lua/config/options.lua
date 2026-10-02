vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH
-- Disable netrw banner
vim.g.netrw_banner = 0

-- line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- soft wrap, never hard wrap
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.textwidth = 0
vim.opt.formatoptions:remove("t")

-- backup and undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- search
vim.opt.inccommand = "split"

-- UI
vim.opt.background = "dark"
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

-- folding (for nvim-ufo)
vim.o.foldenable = true
vim.o.foldmethod = "manual"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldcolumn = "0"

-- window splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- misc
vim.opt.guicursor = ""
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
vim.opt.clipboard:append("unnamedplus")
vim.opt.mouse = "a"
vim.opt.cursorline = true
