#!/usr/bin/env bash
set -euo pipefail

# Fedora helper for the repo .zshrc.
# Installs zsh, optional completion/highlight plugins, and oh-my-posh when
# available from enabled repositories. The upstream oh-my-posh installer is only
# used when explicitly requested.

ALLOW_UPSTREAM_OH_MY_POSH=false

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

usage() {
  cat <<'EOF'
Usage:
  scripts/install-zsh-deps-fedora.sh [options]

Options:
  --allow-upstream-oh-my-posh
      If oh-my-posh is not available in DNF, install it with the official
      upstream installer. This downloads and runs the upstream install script.

  -h, --help
      Show this help.

Installed when available:
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  oh-my-posh
EOF
}

while (($# > 0)); do
  case "$1" in
    --allow-upstream-oh-my-posh)
      ALLOW_UPSTREAM_OH_MY_POSH=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
  shift
done

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

check_sudo() {
  command_exists sudo || die "sudo не найден."
  sudo -v
}

package_available() {
  local package="$1"
  local arch
  arch="$(rpm -E '%{_arch}')"

  rpm -q "${package}" >/dev/null 2>&1 && return 0

  dnf -q repoquery --available --qf '%{name} %{arch}' "${package}" 2>/dev/null |
    awk -v package="${package}" -v arch="${arch}" \
      '$1 == package && ($2 == arch || $2 == "noarch") { found = 1 } END { exit found ? 0 : 1 }'
}

install_dnf_package() {
  local package="$1"

  if rpm -q "${package}" >/dev/null 2>&1; then
    log "Пакет уже установлен: ${package}"
    return 0
  fi

  if ! package_available "${package}"; then
    warn "Пакет не найден в подключенных DNF-репозиториях: ${package}"
    return 1
  fi

  log "Устанавливаю пакет: ${package}"
  sudo dnf install -y "${package}"
}

install_oh_my_posh_upstream() {
  if command_exists oh-my-posh; then
    log "oh-my-posh уже установлен: $(command -v oh-my-posh)"
    return 0
  fi

  if [[ "${ALLOW_UPSTREAM_OH_MY_POSH}" != true ]]; then
    warn "oh-my-posh не найден в DNF."
    warn "Для fallback установки запусти: $0 --allow-upstream-oh-my-posh"
    return 0
  fi

  command_exists curl || install_dnf_package curl || die "curl нужен для upstream установки oh-my-posh."

  log "Устанавливаю oh-my-posh через официальный upstream installer"
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "${HOME}/.local/bin"
}

main() {
  command_exists dnf || die "Этот скрипт рассчитан на Fedora с dnf."
  check_sudo

  install_dnf_package zsh || die "zsh обязателен для .zshrc."
  install_dnf_package zsh-autosuggestions || warn ".zshrc продолжит работать без autosuggestions."
  install_dnf_package zsh-syntax-highlighting || warn ".zshrc продолжит работать без syntax highlighting."

  if ! install_dnf_package oh-my-posh; then
    install_oh_my_posh_upstream
  fi

  cat <<'EOF'

Zsh dependency check:
EOF

  for command_name in zsh oh-my-posh; do
    if command_exists "${command_name}"; then
      printf '  %-12s %s\n' "${command_name}" "$(command -v "${command_name}")"
    else
      printf '  %-12s %s\n' "${command_name}" "не найден в PATH"
    fi
  done

  for plugin_file in \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
    if [[ -f "${plugin_file}" ]]; then
      printf '  %-12s %s\n' "plugin" "${plugin_file}"
    else
      printf '  %-12s %s\n' "plugin" "не найден: ${plugin_file}"
    fi
  done

  cat <<'EOF'

Notes:
- Private exports stay in ~/.zshrc.local or ~/.zshrc_custom.
- Link the dotfiles with: ./scripts/install.sh
- Start a fresh shell with: exec zsh
EOF
}

main "$@"
