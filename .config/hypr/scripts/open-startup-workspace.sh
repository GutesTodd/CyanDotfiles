#!/usr/bin/env bash
set -euo pipefail

workspace="1"
monitors_json="$(hyprctl monitors -j)"

if command -v jq >/dev/null; then
  jq -r '.[] | select(.class | test("^startup-")) | .address' <<<"$(hyprctl clients -j)" |
    while read -r address; do
      [[ -n "${address}" ]] && hyprctl dispatch closewindow "address:${address}" >/dev/null || true
    done
fi

focused_monitor="$(jq -r '.[] | select(.focused == true) | .name' <<<"${monitors_json}" | head -n1)"
if [[ -z "${focused_monitor}" || "${focused_monitor}" == "null" ]]; then
  focused_monitor="$(jq -r '.[0].name' <<<"${monitors_json}")"
fi

if [[ -n "${focused_monitor}" && "${focused_monitor}" != "null" ]]; then
  hyprctl dispatch focusmonitor "${focused_monitor}" >/dev/null
fi

hyprctl dispatch workspace "${workspace}" >/dev/null

hyprctl dispatch exec "kitty --class startup-fastfetch --title startup-fastfetch sh -lc 'command -v fastfetch >/dev/null && fastfetch; exec \"\$SHELL\" -l'" >/dev/null
sleep 0.60

hyprctl dispatch layoutmsg preselect r >/dev/null
hyprctl dispatch exec "kitty --class startup-btm --title startup-btm sh -lc 'if command -v btm >/dev/null; then exec btm; elif [ -x \"\$HOME/.cargo/bin/btm\" ]; then exec \"\$HOME/.cargo/bin/btm\"; else printf \"btm is not installed\\n\"; exec \"\$SHELL\" -l; fi'" >/dev/null
sleep 0.60

hyprctl dispatch focuswindow "class:^startup-fastfetch$" >/dev/null || true
hyprctl dispatch layoutmsg preselect d >/dev/null
hyprctl dispatch exec "kitty --class startup-yazi --title startup-yazi sh -lc 'if command -v yazi >/dev/null; then exec yazi; else printf \"yazi is not installed\\n\"; exec \"\$SHELL\" -l; fi'" >/dev/null
sleep 0.60

hyprctl dispatch focuswindow "class:^startup-btm$" >/dev/null || true
hyprctl dispatch layoutmsg preselect d >/dev/null
hyprctl dispatch exec "kitty --class startup-shell --title startup-shell" >/dev/null
