#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backup_dir="${HOME}/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

configs=(
  hypr
  waybar
  kitty
  ohmyposh
  rofi
  swappy
  bottom
  nvim
)

home_files=(
  .zshrc
)

mkdir -p "${HOME}/.config" "${backup_dir}"

for name in "${configs[@]}"; do
  src="${repo_dir}/.config/${name}"
  dst="${HOME}/.config/${name}"

  [[ -e "${src}" ]] || continue

  if [[ -e "${dst}" || -L "${dst}" ]]; then
    mv "${dst}" "${backup_dir}/${name}"
  fi

  ln -s "${src}" "${dst}"
done

for name in "${home_files[@]}"; do
  src="${repo_dir}/${name}"
  dst="${HOME}/${name}"

  [[ -e "${src}" ]] || continue

  if [[ -e "${dst}" || -L "${dst}" ]]; then
    mv "${dst}" "${backup_dir}/${name}"
  fi

  ln -s "${src}" "${dst}"
done

plugin_dir="${HOME}/.config/hypr/plugins/split-monitor-workspaces"
if [[ ! -d "${plugin_dir}" ]]; then
  mkdir -p "$(dirname "${plugin_dir}")"
  git clone https://github.com/zjeffer/split-monitor-workspaces "${plugin_dir}"
fi

echo "Dotfiles installed."
echo "Backup directory: ${backup_dir}"
echo "Reload Hyprland with: hyprctl reload"
