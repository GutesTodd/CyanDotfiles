#!/usr/bin/env bash
set -euo pipefail

save_dir="${HOME}/Pictures/Screenshots"
mkdir -p "${save_dir}"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "screenshot" "$1"
  fi
}

choose() {
  local prompt="$1"
  shift
  printf '%s\n' "$@" | rofi -dmenu -i -p "${prompt}"
}

target="$(choose capture area screen active output)"
[ -n "${target}" ] || exit 0

mode="$(choose output save copy edit copy+save)"
[ -n "${mode}" ] || exit 0

stamp="$(date +%Y%m%d-%H%M%S)"
file="${save_dir}/shot-${stamp}.png"

case "${mode}" in
  save)
    grimblast --notify save "${target}" "${file}"
    notify "saved ${file}"
    ;;
  copy)
    grimblast --notify copy "${target}"
    notify "copied to clipboard"
    ;;
  edit)
    tmp="$(mktemp --suffix=.png)"
    grimblast save "${target}" "${tmp}"
    if command -v swappy >/dev/null 2>&1; then
      GTK_THEME=Adwaita:dark swappy -f "${tmp}" -o "${file}"
    else
      grimblast edit "${target}"
    fi
    notify "edited ${file}"
    ;;
  copy+save)
    grimblast --notify copysave "${target}" "${file}"
    notify "saved and copied ${file}"
    ;;
esac
