hl.window_rule({
    name = "kitty-opacity",
    match = { class = "^(kitty)$" },
    opacity = "0.94 0.86",
})

hl.window_rule({
    name = "hacknet-boot-float",
    match = { class = "^(hacknet-boot)$" },
    float = true,
    center = true,
})

hl.window_rule({
    name = "open-file-dialog-float",
    match = { title = "^(Open File)$" },
    float = true,
})

hl.window_rule({
    name = "save-file-dialog-float",
    match = { title = "^(Save File)$" },
    float = true,
})

hl.window_rule({
    name = "picture-in-picture-float",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    keep_aspect_ratio = true,
})
