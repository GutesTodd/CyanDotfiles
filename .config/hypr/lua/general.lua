hl.config({
    general = {
        gaps_in = 3,
        gaps_out = { top = 6, right = 18, bottom = 6, left = 18 },
        border_size = 1,
        col = {
            active_border = { colors = { "rgb(7fb6c9)", "rgb(355d78)" }, angle = 35 },
            inactive_border = "rgb(172836)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,

        blur = {
            enabled = false,
        },

        shadow = {
            enabled = false,
        },
    },

    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("cyber", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "cyber", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "cyber", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "cyber" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "cyber" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "cyber", style = "slide" })
