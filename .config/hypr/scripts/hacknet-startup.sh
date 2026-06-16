#!/usr/bin/env bash
set -euo pipefail

script_dir="${HOME}/.config/hypr/scripts"

if command -v kitty >/dev/null; then
  kitty --class hacknet-boot --title hacknet-boot "${script_dir}/hacknet-boot-sequence.sh" || true
fi

"${script_dir}/open-startup-workspace.sh"
