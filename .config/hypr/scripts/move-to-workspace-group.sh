#!/usr/bin/env bash
set -euo pipefail

group="${1:-}"

if [[ -z "${group}" || ! "${group}" =~ ^[0-9]+$ || "${group}" -lt 1 || "${group}" -gt 9 ]]; then
  exit 1
fi

current_workspace="$(hyprctl activeworkspace -j | jq -r '.id')"
workspace_block="$(((current_workspace / 10) * 10))"
target_workspace="$((workspace_block + group))"

hyprctl dispatch movetoworkspace "${target_workspace}" >/dev/null
