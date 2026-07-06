-- ######## Window rules ########

-- No maximize
-- LibreOffice

hl.window_rule({
    match = {
        class = "^libreoffice-.*$"
    },
    tile = true,
    suppress_event = "maximize fullscreen"
})

hl.window_rule({
    match = {
        class = "org.telegram.desktop"
    },
    no_initial_focus = true
})

-- Anki

hl.window_rule({
    match = {
        title = "^AwesomeTTS: Add TTS Audio to Note$"
    },
    center = true
})

-- Silent workspace assignment

hl.window_rule({
    match = {
        class = "firefox"
    },
    workspace = "1"
})

hl.window_rule({
    match = {
        class = "obsidian"
    },
    workspace = "3 silent"
})

hl.window_rule({
    match = {
        class = "Spotify"
    },
    workspace = "4 silent"
})

-- Rider / JetBrains

-- Fix tooltips (title = win.<id>)

hl.window_rule({
    match = {
        class = "^(.*jetbrains.*)$",
        title = "^(win.*)$"
    },
    no_initial_focus = true
})

hl.window_rule({
    match = {
        class = "^(.*jetbrains.*)$",
        title = "^(win.*)$"
    },
    no_focus = true
})

-- Fix tab dragging (single space title)

hl.window_rule({
    match = {
        class = "^(.*jetbrains.*)$",
        title = "^\\s$"
    },
    no_initial_focus = true,
    no_focus = true
})

-- Fix Settings window
hl.window_rule({
    match = {
        class = "^(.*jetbrains.*)$",
        title = "^(Settings)$"
    },
    stay_focused = true
})

-- Godot
hl.window_rule({
    name = "godot-main-editor",
    match = {
        class = "^org%.godotengine%.Editor$",
        title = "Godot Engine$"
    },
    float = false,
})

-- Godot project editor
hl.window_rule({
    name = "godot-submenus-focus",
    match = {
        class = "^org%.godotengine%.Editor$",
        float = true
    },
    float = true,
    focus_on_activate = true,
})

-- Godot project manager
hl.window_rule({
    name = "godot-project-manager",
    match = {
        class = "^org%.godotengine%.ProjectManager$"
    },
    float = false,
})
