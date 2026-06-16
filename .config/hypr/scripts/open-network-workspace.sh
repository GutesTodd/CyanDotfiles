#!/usr/bin/env bash
set -euo pipefail

hyprctl dispatch workspace 2 >/dev/null

if ! command -v kitty >/dev/null; then
  printf "kitty is required for the Network workspace.\n" >&2
  exit 1
fi

mode="${1:-tshark}"
capture_script="${HOME}/.config/hypr/scripts/network-capture.sh"

case "${mode}" in
  tshark)
    hyprctl dispatch exec "kitty --title network-tshark ${capture_script} tshark" >/dev/null
    ;;
  termshark)
    hyprctl dispatch exec "kitty --title network-termshark ${capture_script} termshark" >/dev/null
    ;;
  *)
    printf "Usage: %s [tshark|termshark]\n" "$0" >&2
    exit 2
    ;;
esac
