# Cyan Hyprland Dotfiles

Personal Fedora + Hyprland 0.55+ dotfiles with a muted Hacknet / Hyprlust-inspired style.

Focus:

- Lua-based Hyprland config
- KDE-like grouped workspaces for multiple monitors
- lightweight terminal-first workstation
- Waybar, Kitty, Zsh, Rofi, Swappy, bottom, LazyVim theme
- no QuickShell, no ML4W widgets, no background workspace daemons

## Layout

```text
.config/
  hypr/
  waybar/
  kitty/
  ohmyposh/
  zen/
  rofi/
  swappy/
  bottom/
  nvim/
scripts/
  install.sh
```

Home-level files:

```text
.zshrc
```

## Install

Review the files first, install dependencies, then link the dotfiles:

```bash
./scripts/install-deps-fedora.sh
./scripts/install-zsh-deps-fedora.sh
./scripts/install.sh
```

If `oh-my-posh` is not available in enabled Fedora repositories, the zsh helper can use
the official upstream installer only when explicitly requested:

```bash
./scripts/install-zsh-deps-fedora.sh --allow-upstream-oh-my-posh
```

The dependency script targets Fedora 43/44. Optional Flatpak setup:

```bash
./scripts/install-deps-fedora.sh --enable-flathub
./scripts/install-deps-fedora.sh --install-zen
```

For Fedora 43 Everything with Hyprland from COPR `lionheartp/Hyprland`,
there is also a focused helper for tools that may be missing from the base install:

```bash
chmod +x scripts/install-hypr-tools.sh
./scripts/install-hypr-tools.sh
```

By default this installs Kvantum as the Qt theme backend. To use `qt6ct` instead:

```bash
./scripts/install-hypr-tools.sh --qt-theme-backend qt6ct
```

To switch Qt styling from `qt6ct` to Kvantum:

```bash
chmod +x scripts/switch-qt-theme-to-kvantum.sh
./scripts/switch-qt-theme-to-kvantum.sh
```

To install the Zen Browser UI customizations into the active Flatpak profile:

```bash
chmod +x scripts/install-zen-config.sh
./scripts/install-zen-config.sh
```

The script backs up existing config directories to `~/.config/dotfiles-backup-<timestamp>/`,
creates symlinks, and clones `split-monitor-workspaces` for the Hyprland Lua workspace logic.
Keep private shell exports such as proxies, API keys, and machine-local credentials in
`~/.zshrc.local` or the legacy `~/.zshrc_custom`; both files are intentionally ignored.

Wallpaper assets are included in:

```text
.config/hypr/assets/
  wallpaper.png
  lockscreen.jpg
```

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
