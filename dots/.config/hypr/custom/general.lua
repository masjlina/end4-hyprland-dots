hl.config({
    general = {
        border_size = 3
    },

    input = {
        kb_layout = "us, ru, ua",
        kb_options = "grp:alt_shift_toggle,caps:swapescape"
    },

    group = {
        groupbar = {
            gradients = true,
            gradient_rounding = 6,
            rounding = 10,
            gradient_round_only_edges = false,
            gaps_in = 7
        }
    }
})

-- Special workspace animations

hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 2.8,
    bezier = "emphasizedDecel",
    style = "slide top"
})

hl.animation({
    leaf = "specialWorkspaceOut",
    enabled = true,
    speed = 1.2,
    bezier = "emphasizedAccel",
    style = "slide bottom"
})
