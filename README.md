# Cyan Hyprland Dotfiles

Personal Fedora + Hyprland 0.55+ dotfiles with a muted Hacknet / Hyprlust-inspired style.

Focus:

- Lua-based Hyprland config
- KDE-like grouped workspaces for multiple monitors
- lightweight terminal-first workstation
- Waybar, Kitty, Rofi, Swappy, bottom, LazyVim theme
- no QuickShell, no ML4W widgets, no background workspace daemons

## Layout

```text
.config/
  hypr/
  waybar/
  kitty/
  rofi/
  swappy/
  bottom/
  nvim/
scripts/
  install.sh
```

## Install

Review the files first, then run:

```bash
./scripts/install.sh
```

The script backs up existing config directories to `~/.config/dotfiles-backup-<timestamp>/`,
creates symlinks, and clones `split-monitor-workspaces` for the Hyprland Lua workspace logic.

## Workspace Model

Workspace groups are calculated as:

```text
workspace = group + ((monitorIndex - 1) * 10)
```

Examples:

- monitor 1: `1 2 3 4 5`
- monitor 2: `11 12 13 14 15`
- monitor 3: `21 22 23 24 25`

Hotkeys:

- `SUPER + 1..5` switches the group on all monitors
- `SUPER + SHIFT + 1..5` moves the active window to that group on the current monitor
- `SUPER + CTRL + 1..5` moves the active window and switches there
- `SUPER + TAB` focuses the next monitor
- `SUPER + SHIFT + TAB` moves the active window to the next monitor's workspace in the same group

## Notes

This repo intentionally excludes secrets, browser profiles, SSH keys, Git credentials, Docker config,
and machine-specific runtime state.
