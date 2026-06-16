#!/usr/bin/env bash
set -euo pipefail

group="${1:-}"

if [[ -z "${group}" || ! "${group}" =~ ^[0-9]+$ || "${group}" -lt 1 || "${group}" -gt 9 ]]; then
  exit 1
fi

monitors_json="$(hyprctl monitors -j)"
monitor_count="$(jq 'length' <<<"${monitors_json}")"

if (( monitor_count <= 1 )); then
  hyprctl dispatch workspace "${group}" >/dev/null
  exit 0
fi

read -r monitor_index current_workspace < <(
  jq -r '
    sort_by(.x, .y) as $monitors
    | ($monitors | map(.focused) | index(true)) as $idx
    | "\($idx // 0) \($monitors[$idx // 0].activeWorkspace.id)"
  ' <<<"${monitors_json}"
)

current_group="$((current_workspace % 10))"
target_workspace="$((monitor_index * 10 + group))"

if (( current_group == group )); then
  hyprctl dispatch focusmonitor +1 >/dev/null
  exit 0
fi

hyprctl dispatch workspace "${target_workspace}" >/dev/null
