-- CachyOS Hyprland Configuration

require("config.animations")
require("config.autostart")
require("config.colors")
require("config.decorations")
require("config.variables")
require("config.environment")
require("config.inputs")
require("config.binds")
require("config.misc")
require("config.monitors")
require("config.windowrules")
require("config.workspaces")

hl.config({
    input = {
        kb_options = "caps:backspace",
        touchpad = {
            tap_to_click = true,
            clickfinger_behavior = true,
        }
    }
})
