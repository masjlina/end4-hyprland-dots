require("hyprland.variables")
require("custom.variables")

local SCRIPTS = "$HOME/.config/hypr/custom/scripts"
local CONFIGS = "$HOME/.config/hypr/hyprland"

-- ######## Dwindle Layout ########

hl.bind(
    "SUPER + SHIFT + I",
    hl.dsp.layout("togglesplit"),
    { description = "Toggle split" }
)

-- ######## Window ########

hl.unbind("SUPER + CTRL + Q")

hl.bind(
    "SUPER + CTRL + SHIFT + Q",
    hl.dsp.exec_cmd("hyprctl kill"),
    { description = "Force kill window" }
)

-- Resize windows
hl.unbind("SUPER + SHIFT + Left")
hl.unbind("SUPER + SHIFT + Right")
hl.unbind("SUPER + SHIFT + Up")
hl.unbind("SUPER + SHIFT + Down")

hl.bind(
    "SUPER + SHIFT + Left",
    hl.dsp.window.resize({
        x = -50,
        y = 0,
        relative = true
    }),
    { repeating = true }
)

hl.bind(
    "SUPER + SHIFT + Right",
    hl.dsp.window.resize({
        x = 50,
        y = 0,
        relative = true
    }),
    { repeating = true }
)

hl.bind(
    "SUPER + SHIFT + Up",
    hl.dsp.window.resize({
        x = 0,
        y = -50,
        relative = true
    }),
    { repeating = true }
)

hl.bind(
    "SUPER + SHIFT + Down",
    hl.dsp.window.resize({
        x = 0,
        y = 50,
        relative = true
    }),
    { repeating = true }
)

-- Move window
hl.unbind("CTRL + SUPER + Right")
hl.unbind("CTRL + SUPER + Left")
hl.unbind("CTRL + SUPER + Up")
hl.unbind("CTRL + SUPER + Down")
hl.unbind("SUPER + CTRL + Right")
hl.unbind("SUPER + CTRL + Left")
hl.unbind("SUPER + CTRL + Up")
hl.unbind("SUPER + CTRL + Down")

hl.bind(
    "CTRL + SUPER + Left",
    hl.dsp.window.move({ direction = "l" })
)

hl.bind(
    "CTRL + SUPER + Right",
    hl.dsp.window.move({ direction = "r" })
)

hl.bind(
    "CTRL + SUPER + Up",
    hl.dsp.window.move({ direction = "u" })
)

hl.bind(
    "CTRL + SUPER + Down",
    hl.dsp.window.move({ direction = "d" })
)

-- ######## Group ########

hl.bind("SUPER + G", hl.dsp.group.toggle())

hl.bind(
    "SUPER + CTRL + SHIFT + TAB",
    hl.dsp.exec_cmd("changegroupactive")
)

hl.bind("SUPER + CTRL + SHIFT + LEFT",  hl.dsp.exec_cmd("moveintogroup l"))
hl.bind("SUPER + CTRL + SHIFT + RIGHT", hl.dsp.exec_cmd("moveintogroup r"))
hl.bind("SUPER + CTRL + SHIFT + UP",    hl.dsp.exec_cmd("moveintogroup u"))
hl.bind("SUPER + CTRL + SHIFT + DOWN",  hl.dsp.exec_cmd("moveintogroup d"))

hl.bind("SUPER + CTRL + Q", hl.dsp.exec_cmd("moveoutofgroup"))

-- ######## Floating ########

hl.bind(
    "SUPER + SHIFT + F",
    hl.dsp.exec_cmd("togglefloating"),
    { description = "Toggle floating" }
)

-- ######## Send to workspace ########

for i = 1, 9 do
    hl.bind(
        "SUPER + CTRL + " .. i,
        hl.dsp.window.move({
            workspace = i,
            follow = false
        })
    )
end

hl.bind(
    "SUPER + CTRL + 0",
    hl.dsp.window.move({
        workspace = 10,
        follow = false
    })
)

-- ######## Alt tab ########

hl.bind(
    "ALT + TAB",
    hl.dsp.window.cycle_next()
)

hl.bind(
    "ALT + TAB",
    hl.dsp.window.alter_zorder({
        mode = "top"
    })
)

-- ######## Special workspace ########

hl.bind(
    "SUPER + SHIFT + RETURN",
    hl.dsp.exec_cmd("togglespecialworkspace term")
)

-- ######## Screenshot ########

hl.unbind("CTRL + PRINT")

hl.bind(
    "CTRL + PRINT",
    hl.dsp.exec_cmd(
        'mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim -g "$(slurp)" - | tee $(xdg-user-dir PICTURES)/Screenshots/Screenshot_"$(date \'+%Y-%m-%d_%H.%M.%S\')".png | wl-copy'
    )
)

-- ######## Workspace switching ########

for i = 1, 9 do
    hl.bind(
        "SUPER + " .. i,
        hl.dsp.exec_cmd(SCRIPTS .. "/workspace_action.sh workspace " .. i)
    )
end

hl.bind(
    "SUPER + 0",
    hl.dsp.exec_cmd(SCRIPTS .. "/workspace_action.sh workspace 10")
)

-- ######## Apps ########

hl.unbind("SUPER + T")

hl.bind(
    "SUPER + T",
    hl.dsp.exec_cmd(
        '~/.config/hypr/hyprland/scripts/launch_first_available.sh "thunar" "${TERMINAL}" "kitty -1 fish -c yazi"'
    ),
    { description = "File manager" }
)

-- ######## Shell ########

hl.bind("CTRL + SUPER + M", hl.dsp.global("quickshell:monitorModeWidgetToggle"), { description = "Shell: Toggle monitor mode widget" })
