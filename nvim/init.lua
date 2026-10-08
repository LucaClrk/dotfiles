require("config.options")
require("config.keymaps")
require("config.lazy")
require("config.terminalpop") -- floating terminal: <leader>c/

-- Apply the active colorscheme from lua/config/colorscheme.lua (after lazy.nvim, so
-- theme plugins are available). <leader>ths rewrites that file when you pick a theme;
-- `:colorscheme devcpp_light` switches to the hand-written theme in colors/.
require("config.colorscheme")
