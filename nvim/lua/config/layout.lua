-- Keyboard-layout-specific keymaps (AZERTY vs QWERTY).
--
-- Resolution order:
--   1. $NVIM_KEYBOARD_LAYOUT  -- one-off override: NVIM_KEYBOARD_LAYOUT=qwerty nvim
--   2. the state file written by bin/nvim-layout (keep the path in sync)
--   3. "azerty"
--
-- QWERTY needs no extra maps: Vim's defaults were designed for it.

local default = "azerty"
local state_file = vim.fn.stdpath("state") .. "/keyboard-layout"
local valid = { azerty = true, qwerty = true }

local function read_state_file()
    local ok, lines = pcall(vim.fn.readfile, state_file)
    if not ok or type(lines) ~= "table" or not lines[1] then
        return nil
    end
    local name = vim.trim(lines[1])
    return name ~= "" and name or nil
end

local function resolve()
    local name, source
    local from_env = vim.env.NVIM_KEYBOARD_LAYOUT
    if from_env and vim.trim(from_env) ~= "" then
        name, source = vim.trim(from_env), "$NVIM_KEYBOARD_LAYOUT"
    else
        name = read_state_file()
        if name then
            source = state_file
        else
            name, source = default, "default"
        end
    end

    name = name:lower()
    if not valid[name] then
        vim.notify(
            ("Unknown keyboard layout %q from %s, falling back to %q"):format(name, source, default),
            vim.log.levels.WARN
        )
        name, source = default, "default (invalid value from " .. source .. ")"
    end
    return name, source
end

-- On a Belgian/French AZERTY board W and Z are swapped relative to QWERTY and the
-- number row needs Shift. These maps put word motion and the digits back.
local function apply_azerty()
    local map = vim.keymap.set
    local nvo = { "n", "v", "o" }

    map(nvo, "z", "w", { desc = "Move forward one word" })
    map(nvo, "Z", "W", { desc = "Move forward one WORD" })
    -- the old z/Z prefixes (zz, zt, zb, ZZ ...) move to w/W
    map(nvo, "w", "z", { desc = "View/Scroll prefix (was z)" })
    map(nvo, "W", "Z", { desc = "Quit/View prefix (was Z)" })

    -- text objects: daz = daw, ciz = ciw
    map({ "o", "v" }, "az", "aw", { desc = "around word" })
    map({ "o", "v" }, "iz", "iw", { desc = "inner word" })
    map({ "o", "v" }, "aZ", "aW", { desc = "around WORD" })
    map({ "o", "v" }, "iZ", "iW", { desc = "inner WORD" })

    local numbers = {
        ["&"] = "1",
        ["é"] = "2",
        ['"'] = "3",
        ["'"] = "4",
        ["("] = "5",
        ["-"] = "6",
        ["è"] = "7",
        ["_"] = "8",
        ["ç"] = "9",
        ["à"] = "0",
    }
    for symbol, number in pairs(numbers) do
        map(nvo, symbol, number, { desc = "AZERTY " .. number })
    end
end

local name, source = resolve()
if name == "azerty" then
    apply_azerty()
end

vim.api.nvim_create_user_command("KeyboardLayout", function()
    print(("keyboard layout: %s  (from %s)"):format(name, source))
end, { desc = "Show the active keyboard layout" })
