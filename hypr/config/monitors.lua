-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly
-- hl.monitor({
--     output    = MONITOR1,
--     mode      = "1920x1080@60",
--     position  = "0x0",
--     scale     = "1",
-- })

hl.monitor({
    output    = MONITOR1,
    mode      = "1920x1200@60",
    position  = "320x1440", -- Monitors on top of eachother
    -- position  = "0x900", -- Monitors next to eachother
    scale     = "1",
})

hl.monitor({
    output = "desc:Dell Inc. DELL AW2723DF 19WMNP3",
    mode = "2560x1440@144",
    position = "0x0", -- Monitors on top of eachother
    -- position = "1920x0", -- Monitors next to eachother
    scale = "1",
})
