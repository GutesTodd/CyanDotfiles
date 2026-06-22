#!/usr/bin/env bash
set -euo pipefail

# Install only safe Zen Browser customization files:
# user.js, chrome/userChrome.css, chrome/userContent.css.
# Do not touch prefs.js, cookies, history, sessions, passwords, or extensions.

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
zen_root="${HOME}/.var/app/app.zen_browser.zen/.zen"
backup_dir="${HOME}/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)/zen"
profile_path=""

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

find_default_profile() {
  local profiles_ini="${zen_root}/profiles.ini"
  local section=""
  local current_profile_path=""
  local first_path=""
  local profile_default_path=""
  local install_default_path=""

  [[ -f "${profiles_ini}" ]] || die "Zen profiles.ini не найден: ${profiles_ini}"

  while IFS='=' read -r key value; do
    if [[ "${key}" == \[*\] ]]; then
      section="${key#[}"
      section="${section%]}"
      current_profile_path=""
      continue
    fi

    case "${key}" in
      Path)
        [[ -z "${first_path}" ]] && first_path="${value}"
        current_profile_path="${value}"
        ;;
      Default)
        if [[ "${section}" == Install* ]]; then
          install_default_path="${value}"
        elif [[ "${value}" == "1" && -n "${current_profile_path}" ]]; then
          profile_default_path="${current_profile_path}"
        fi
        ;;
    esac
  done < "${profiles_ini}"

  if [[ -n "${install_default_path}" && -d "${zen_root}/${install_default_path}" ]]; then
    profile_path="${zen_root}/${install_default_path}"
    return 0
  fi

  if [[ -n "${profile_default_path}" && -d "${zen_root}/${profile_default_path}" ]]; then
    profile_path="${zen_root}/${profile_default_path}"
    return 0
  fi

  if [[ -n "${first_path}" ]]; then
    warn "Default profile не найден явно; использую первый профиль из profiles.ini."
    profile_path="${zen_root}/${first_path}"
    return 0
  fi

  die "Не удалось определить профиль Zen из ${profiles_ini}"
}

link_file() {
  local source_file="$1"
  local target_file="$2"
  local relative_target="${target_file#${HOME}/}"

  [[ -f "${source_file}" ]] || return 0

  mkdir -p "$(dirname "${target_file}")" "${backup_dir}/$(dirname "${relative_target}")"

  if [[ -e "${target_file}" || -L "${target_file}" ]]; then
    if [[ -L "${target_file}" && "$(readlink "${target_file}")" == "${source_file}" ]]; then
      log "Уже подключено: ${target_file}"
      return 0
    fi

    log "Backup: ${target_file}"
    mv "${target_file}" "${backup_dir}/${relative_target}"
  fi

  ln -s "${source_file}" "${target_file}"
  log "Linked: ${target_file} -> ${source_file}"
}

main() {
  [[ -d "${zen_root}" ]] || die "Zen Flatpak profile root не найден: ${zen_root}"

  find_default_profile
  [[ -d "${profile_path}" ]] || die "Zen profile directory не найден: ${profile_path}"

  log "Zen profile: ${profile_path}"

  link_file "${repo_dir}/.config/zen/user.js" "${profile_path}/user.js"
  link_file "${repo_dir}/.config/zen/chrome/userChrome.css" "${profile_path}/chrome/userChrome.css"
  link_file "${repo_dir}/.config/zen/chrome/userContent.css" "${profile_path}/chrome/userContent.css"

  log "Zen config installed."
  log "Backup directory: ${backup_dir}"
  warn "Перезапусти Zen Browser, чтобы userChrome.css применился."
}

main "$@"
