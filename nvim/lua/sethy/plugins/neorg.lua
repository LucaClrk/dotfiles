return {
  "nvim-neorg/neorg",
  lazy = false, -- Neorg is best loaded at startup for filetype detection
  version = "*",
  dependencies = { "nvim-treesitter/nvim-treesitter"},
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {}, -- Loads default behavior
        ["core.concealer"] = {}, -- Adds icons and hides markup symbols
        ["core.integrations.treesitter"] = {
          config = {
            warn_missing_parsers = false, -- This stops the annoying startup error
          },
        },
        ["core.dirman"] = { -- Manages your notes folders
          config = {
            workspaces = {
              notes = "~/notes",
            },
            default_workspace = "notes",
            autochdir = true,
          },
        },
      },
    })
  end,
}
