#!/usr/bin/env bash
set -euo pipefail

# Переключает Qt theme backend с qt6ct на Kvantum для Hyprland-конфига.
# Скрипт безопасный: делает бэкап файлов, не удаляет qt6ct и не использует --allowerasing.

THEME_BACKEND="kvantum"
BACKUP_DIR="${HOME}/.config/dotfiles-backup-kvantum-$(date +%Y%m%d-%H%M%S)"

log() {
  printf '\033[1;36m[INFO]\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33m[WARN]\033[0m %s\n' "$*" >&2
}

die() {
  printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

dnf_package_available() {
  local package="$1"
  local arch
  arch="$(rpm -E '%{_arch}')"

  rpm -q "${package}" >/dev/null 2>&1 && return 0

  dnf -q repoquery --available --qf '%{name} %{arch}' "${package}" 2>/dev/null |
    awk -v package="${package}" -v arch="${arch}" \
      '$1 == package && ($2 == arch || $2 == "noarch") { found = 1 } END { exit found ? 0 : 1 }'
}

install_kvantum() {
  if command_exists kvantummanager || rpm -q kvantum >/dev/null 2>&1; then
    log "Kvantum уже установлен."
    return 0
  fi

  if ! command_exists dnf; then
    die "dnf не найден. Этот скрипт рассчитан на Fedora."
  fi

  if ! dnf_package_available kvantum; then
    die "Пакет kvantum не найден в подключенных DNF-репозиториях."
  fi

  log "Устанавливаю Kvantum через DNF"
  sudo dnf install -y kvantum
}

backup_file() {
  local file="$1"
  local relative="${file#${HOME}/}"
  local target="${BACKUP_DIR}/${relative}"

  mkdir -p "$(dirname "${target}")"
  cp -a "${file}" "${target}"
}

replace_in_file() {
  local file="$1"

  [[ -f "${file}" ]] || return 0

  if ! grep -q 'QT_QPA_PLATFORMTHEME' "${file}" && ! grep -q 'qt6ct' "${file}"; then
    return 0
  fi

  log "Правлю ${file}"
  backup_file "${file}"

  sed -i \
    -e 's/QT_QPA_PLATFORMTHEME,qt6ct/QT_QPA_PLATFORMTHEME,kvantum/g' \
    -e 's/QT_QPA_PLATFORMTHEME", "qt6ct"/QT_QPA_PLATFORMTHEME", "kvantum"/g' \
    -e 's/QT_QPA_PLATFORMTHEME=qt6ct/QT_QPA_PLATFORMTHEME=kvantum/g' \
    "${file}"
}

switch_hypr_env_files() {
  local repo_dir
  repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  local files=(
    "${HOME}/.config/hypr/lua/env.lua"
    "${HOME}/.config/hypr/conf/env.conf"
    "${HOME}/.config/hypr/conf/environments.conf"
    "${repo_dir}/.config/hypr/lua/env.lua"
    "${repo_dir}/.config/hypr/conf/env.conf"
    "${repo_dir}/.config/hypr/conf/environments.conf"
  )

  local file
  for file in "${files[@]}"; do
    replace_in_file "${file}"
  done
}

print_summary() {
  cat <<EOF

Kvantum переключение завершено.

Backend:
  QT_QPA_PLATFORMTHEME=${THEME_BACKEND}

Бэкап измененных файлов:
  ${BACKUP_DIR}

Проверка:
  rg -n "QT_QPA_PLATFORMTHEME|qt6ct|kvantum" ~/.config/hypr
  hyprctl reload

Для настройки темы открой:
  kvantummanager
EOF
}

main() {
  install_kvantum
  mkdir -p "${BACKUP_DIR}"
  switch_hypr_env_files
  print_summary
}

main "$@"
