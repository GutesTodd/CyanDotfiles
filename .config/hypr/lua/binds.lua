local mainMod = "SUPER"
local smw = require("lua/workspaces")

local term = "kitty"
local fileManager = "kitty -e yazi"
local launcher = "rofi -show drun"
local browser = "flatpak run app.zen_browser.zen"
local assistant = "kitty -e codex"
local screenshotTool = "~/.config/hypr/scripts/hacknet-screenshot.sh"

local function sortedMonitors()
    local monitors = hl.get_monitors()
    table.sort(monitors, function(a, b)
        if a.x == b.x then
            return a.y < b.y
        end
        return a.x < b.x
    end)
    return monitors
end

local function monitorIndexById(monitorId)
    local monitors = sortedMonitors()
    for index, monitor in ipairs(monitors) do
        if monitor.id == monitorId then
            return index
        end
    end

    return 1
end

local function workspaceForGroup(group, monitorIndex)
    return group + ((monitorIndex - 1) * 10)
end

local function activeWorkspaceGroup()
    local monitor = hl.get_active_monitor()
    if not monitor or not monitor.active_workspace then
        return 1
    end

    local workspaceId = tonumber(monitor.active_workspace.name)
    if not workspaceId then
        return 1
    end

    return ((workspaceId - 1) % 10) + 1
end

local function switchWorkspaceGroup(group)
    return function()
        local monitors = sortedMonitors()
        if #monitors == 0 then
            return
        end

        local focusedMonitor = hl.get_active_monitor()
        local focusedId = focusedMonitor and focusedMonitor.id

        for index, monitor in ipairs(monitors) do
            local targetWorkspace = tostring(workspaceForGroup(group, index))
            if monitor.id ~= focusedId then
                hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
                hl.dispatch(hl.dsp.focus({ workspace = targetWorkspace }))
            end
        end

        local focusedIndex = focusedMonitor and monitorIndexById(focusedMonitor.id) or 1
        hl.dispatch(hl.dsp.focus({ workspace = tostring(workspaceForGroup(group, focusedIndex)) }))
    end
end

local function moveToWorkspaceGroup(group)
    return function()
        local monitor = hl.get_active_monitor()
        local monitorIndex = monitor and monitorIndexById(monitor.id) or 1
        local targetWorkspace = tostring(workspaceForGroup(group, monitorIndex))

        hl.dispatch(hl.dsp.window.move({ workspace = targetWorkspace, follow = false }))
    end
end

local function moveAndFollowWorkspaceGroup(group)
    return function()
        local monitor = hl.get_active_monitor()
        local monitorIndex = monitor and monitorIndexById(monitor.id) or 1
        local targetWorkspace = tostring(workspaceForGroup(group, monitorIndex))

        hl.dispatch(hl.dsp.window.move({ workspace = targetWorkspace, follow = false }))
        switchWorkspaceGroup(group)()
    end
end

local function focusNextMonitor()
    local monitors = sortedMonitors()
    if #monitors < 2 then
        return
    end

    local current = hl.get_active_monitor()
    local currentIndex = 1
    for i, monitor in ipairs(monitors) do
        if current and monitor.id == current.id then
            currentIndex = i
            break
        end
    end

    local nextMonitor = monitors[(currentIndex % #monitors) + 1]
    if nextMonitor then
        hl.dispatch(hl.dsp.focus({ monitor = nextMonitor }))
    end
end

local function moveWindowToNextMonitor()
    local monitors = sortedMonitors()
    if #monitors < 2 then
        return
    end

    local current = hl.get_active_monitor()
    local currentIndex = 1
    for i, monitor in ipairs(monitors) do
        if current and monitor.id == current.id then
            currentIndex = i
            break
        end
    end

    local nextIndex = (currentIndex % #monitors) + 1
    local targetWorkspace = tostring(workspaceForGroup(activeWorkspaceGroup(), nextIndex))

    hl.dispatch(hl.dsp.window.move({ workspace = targetWorkspace, follow = false }))
end

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(assistant))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = 1 }))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

if smw then
    for i = 1, 5 do
        local n = tostring(i)
        hl.bind(mainMod .. " + " .. n, switchWorkspaceGroup(i))
        hl.bind(mainMod .. " + SHIFT + " .. n, moveToWorkspaceGroup(i))
        hl.bind(mainMod .. " + CTRL + " .. n, moveAndFollowWorkspaceGroup(i))
    end
else
    for i = 1, 5 do
        local n = tostring(i)
        hl.bind(mainMod .. " + " .. n, hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. n, hl.dsp.window.move({ workspace = i }))
        hl.bind(mainMod .. " + CTRL + " .. n, hl.dsp.window.move({ workspace = i }))
    end
end

hl.bind(mainMod .. " + TAB", focusNextMonitor)
hl.bind(mainMod .. " + SHIFT + TAB", moveWindowToNextMonitor)

hl.bind("Print", hl.dsp.exec_cmd(screenshotTool))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("sh -lc 'command -v cliphist >/dev/null && cliphist list | rofi -dmenu -p clip | cliphist decode | wl-copy'"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/hacknet-startup.sh"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("~/.config/hypr/scripts/open-network-workspace.sh"))

hl.bind("F1", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true })
hl.bind("F2", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("F3", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("F4", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true })
hl.bind("F5", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("F9", hl.dsp.exec_cmd("hyprlock"))
hl.bind("F11", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })
hl.bind("F12", hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true, locked = true })

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
