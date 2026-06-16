-- Planned workspace organization:
-- 1 = Development
-- 2 = Network
-- 3 = Knowledge
-- 4 = Infrastructure
--
-- split-monitor-workspaces allocates contiguous monitor ranges.
-- Use ten slots per monitor so visible groups become:
-- monitor 1 = 1..5, monitor 2 = 11..15, monitor 3 = 21..25.

local home = assert(os.getenv("HOME"), "HOME is not set")
package.path = package.path .. ";" .. home .. "/.config/hypr/plugins/split-monitor-workspaces/lua/?.lua"

local ok, smw = pcall(require, "split-monitor-workspaces")
if ok then
    smw.setup({
        workspace_count = 10,
        keep_focused = true,
        enable_notifications = false,
        enable_persistent_workspaces = true,
        enable_wrapping = false,
        link_monitors = false,
    })

    return smw
end

return nil
