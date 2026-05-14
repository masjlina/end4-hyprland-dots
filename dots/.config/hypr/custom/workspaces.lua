-- Monitor 1
hl.workspace_rule({
    workspace = "1",
    monitor = "eDP-1",
    default = true,
})

hl.workspace_rule({
    workspace = "3",
    monitor = "eDP-1",
})

hl.workspace_rule({
    workspace = "5",
    monitor = "eDP-1",
})

-- Monitor 2
hl.workspace_rule({
    workspace = "2",
    monitor = "DP-2",
    default = true,
})

hl.workspace_rule({
    workspace = "4",
    monitor = "DP-2",
})

hl.workspace_rule({
    workspace = "6",
    monitor = "DP-2",
})

-- Special workspace
hl.workspace_rule({
    workspace = "special:term",
    on_created_empty = "[float; move (monitor_w/4) (monitor_h*0.05); size (monitor_w*0.5) (monitor_h*0.5)] kitty",
})
