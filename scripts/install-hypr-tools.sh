#!/usr/bin/env bash
set -euo pipefail

# Fedora 43 Everything helper for missing Hyprland workstation tools.
# Hyprland itself is assumed to come from COPR lionheartp/Hyprland.
# This script intentionally does not enable COPR solopasha/hyprland.

FEDORA_VERSION_REQUIRED="43"
BUILD_DIR="${HOME}/build"
LOCAL_BIN="/usr/local/bin"
CARGO_BIN="${HOME}/.cargo/bin"
GO_BIN="${HOME}/go/bin"

HYPRLOCK_REPO="https://github.com/hyprwm/hyprlock"
HYPRPAPER_REPO="https://github.com/hyprwm/hyprpaper"
CLIPHIST_REPO="https://github.com/sentriz/cliphist"

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

check_sudo() {
  command_exists sudo || die "sudo не найден. Установи sudo или запусти команды установки вручную."
  sudo -v
}

check_fedora() {
  local version
  version="$(rpm -E %fedora 2>/dev/null || true)"

  if [[ "${version}" != "${FEDORA_VERSION_REQUIRED}" ]]; then
    warn "Скрипт рассчитан на Fedora ${FEDORA_VERSION_REQUIRED}; обнаружено: ${version:-unknown}."
    warn "Продолжаю, но имена пакетов могут отличаться."
  fi
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

install_dnf_package() {
  local package="$1"

  if rpm -q "${package}" >/dev/null 2>&1; then
    log "Пакет уже установлен: ${package}"
    return 0
  fi

  if ! dnf_package_available "${package}"; then
    warn "Пакет не найден в подключенных DNF-репозиториях: ${package}"
    return 1
  fi

  log "Устанавливаю пакет: ${package}"
  sudo dnf install -y "${package}"
}

install_first_available_dnf_package() {
  local package

  for package in "$@"; do
    if dnf_package_available "${package}"; then
      install_dnf_package "${package}"
      return 0
    fi
  done

  return 1
}

clone_or_update() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "${target_dir}/.git" ]]; then
    log "Обновляю исходники: ${target_dir}"
    git -C "${target_dir}" pull --ff-only
  elif [[ -e "${target_dir}" ]]; then
    die "Путь существует, но это не git-репозиторий: ${target_dir}"
  else
    log "Клонирую ${repo_url} -> ${target_dir}"
    git clone "${repo_url}" "${target_dir}"
  fi
}

install_build_dependencies() {
  log "Устанавливаю базовые зависимости сборки"

  local packages=(
    git
    gcc
    gcc-c++
    make
    cmake
    ninja-build
    meson
    pkgconf-pkg-config
    wayland-devel
    wayland-protocols-devel
    libdrm-devel
    libxkbcommon-devel
    mesa-libEGL-devel
    mesa-libGLES-devel
    mesa-libgbm-devel
    cairo-devel
    pango-devel
    pam-devel
    file-devel
    libjpeg-turbo-devel
    hyprlang-devel
    hyprutils-devel
    hyprgraphics-devel
    hyprcursor-devel
    aquamarine-devel
    sdbus-cpp-devel
  )

  local package
  for package in "${packages[@]}"; do
    install_dnf_package "${package}" || warn "Пропускаю недоступную build dependency: ${package}"
  done
}

build_with_detected_system() {
  local source_dir="$1"
  local binary_name="$2"

  if [[ -f "${source_dir}/CMakeLists.txt" ]]; then
    log "Сборка через CMake/Ninja: ${binary_name}"
    cmake -S "${source_dir}" -B "${source_dir}/build" -G Ninja -DCMAKE_BUILD_TYPE=Release
    cmake --build "${source_dir}/build"

    if cmake --install "${source_dir}/build" --prefix /usr/local --dry-run >/dev/null 2>&1; then
      sudo cmake --install "${source_dir}/build" --prefix /usr/local
    else
      sudo install -Dm755 "${source_dir}/build/${binary_name}" "${LOCAL_BIN}/${binary_name}"
    fi
    return 0
  fi

  if [[ -f "${source_dir}/meson.build" ]]; then
    log "Сборка через Meson/Ninja: ${binary_name}"
    if [[ -d "${source_dir}/build" ]]; then
      meson setup "${source_dir}/build" "${source_dir}" --prefix=/usr/local --buildtype=release --reconfigure
    else
      meson setup "${source_dir}/build" "${source_dir}" --prefix=/usr/local --buildtype=release
    fi
    ninja -C "${source_dir}/build"
    sudo ninja -C "${source_dir}/build" install
    return 0
  fi

  die "Не найден CMakeLists.txt или meson.build в ${source_dir}"
}

build_hyprlock() {
  if command_exists hyprlock; then
    log "hyprlock уже установлен: $(command -v hyprlock)"
    return 0
  fi

  install_build_dependencies
  clone_or_update "${HYPRLOCK_REPO}" "${BUILD_DIR}/hyprlock"
  build_with_detected_system "${BUILD_DIR}/hyprlock" "hyprlock"
}

build_hyprpaper() {
  if command_exists hyprpaper; then
    log "hyprpaper уже установлен: $(command -v hyprpaper)"
    return 0
  fi

  install_build_dependencies
  clone_or_update "${HYPRPAPER_REPO}" "${BUILD_DIR}/hyprpaper"
  build_with_detected_system "${BUILD_DIR}/hyprpaper" "hyprpaper"
}

install_cliphist() {
  if command_exists cliphist; then
    log "cliphist уже установлен: $(command -v cliphist)"
    return 0
  fi

  if install_dnf_package cliphist; then
    return 0
  fi

  install_dnf_package golang || die "golang нужен для сборки cliphist"
  clone_or_update "${CLIPHIST_REPO}" "${BUILD_DIR}/cliphist"

  if [[ -f "${BUILD_DIR}/cliphist/Makefile" ]]; then
    log "Сборка cliphist через make"
    make -C "${BUILD_DIR}/cliphist"
    sudo install -Dm755 "${BUILD_DIR}/cliphist/cliphist" "${LOCAL_BIN}/cliphist"
  else
    log "Сборка cliphist через go build"
    (cd "${BUILD_DIR}/cliphist" && go build -o cliphist .)
    sudo install -Dm755 "${BUILD_DIR}/cliphist/cliphist" "${LOCAL_BIN}/cliphist"
  fi
}

install_yazi() {
  if command_exists yazi; then
    log "yazi уже установлен: $(command -v yazi)"
    return 0
  fi

  if install_dnf_package yazi; then
    return 0
  fi

  install_dnf_package cargo || install_dnf_package rust || die "rust/cargo нужен для установки yazi"

  log "Устанавливаю yazi через cargo"
  cargo install --locked yazi-fm yazi-cli

  if [[ ":${PATH}:" != *":${CARGO_BIN}:"* ]]; then
    warn "${CARGO_BIN} не найден в PATH текущей сессии."
    warn "Добавь в shell config: export PATH=\"\$HOME/.cargo/bin:\$PATH\""
  fi
}

install_termshark() {
  if command_exists termshark; then
    log "termshark уже установлен: $(command -v termshark)"
    return 0
  fi

  if install_dnf_package termshark; then
    return 0
  fi

  install_dnf_package golang || die "golang нужен для установки termshark"

  log "Устанавливаю termshark через go install"
  go install github.com/gcla/termshark/v2/cmd/termshark@latest

  if [[ ":${PATH}:" != *":${GO_BIN}:"* ]]; then
    warn "${GO_BIN} не найден в PATH текущей сессии."
    warn "Добавь в shell config: export PATH=\"\$HOME/go/bin:\$PATH\""
  fi
}

install_bottom() {
  if command_exists btm; then
    log "bottom/btm уже установлен: $(command -v btm)"
    return 0
  fi

  if install_first_available_dnf_package bottom btm; then
    return 0
  fi

  install_dnf_package cargo || install_dnf_package rust || die "rust/cargo нужен для установки bottom"

  log "Устанавливаю bottom через cargo"
  cargo install --locked bottom

  if [[ ":${PATH}:" != *":${CARGO_BIN}:"* ]]; then
    warn "${CARGO_BIN} не найден в PATH текущей сессии."
    warn "Добавь в shell config: export PATH=\"\$HOME/.cargo/bin:\$PATH\""
  fi
}

install_qt6ct() {
  if command_exists qt6ct; then
    log "qt6ct уже установлен: $(command -v qt6ct)"
    return 0
  fi

  install_dnf_package qt6ct || die "qt6ct не найден в подключенных DNF-репозиториях. Ручную сборку не выполняю."
}

install_tshark() {
  if command_exists tshark; then
    log "tshark уже установлен: $(command -v tshark)"
    tshark --version | head -n 1 || true
    return 0
  fi

  local provider
  provider="$(
    dnf -q repoquery --whatprovides '*/tshark' --qf '%{name}' 2>/dev/null |
      awk 'NF && !seen[$1]++ { print $1 }' |
      head -n 1
  )"

  if [[ -z "${provider}" ]]; then
    if dnf_package_available wireshark-cli; then
      provider="wireshark-cli"
    elif dnf_package_available wireshark; then
      provider="wireshark"
    else
      die "Не найден DNF-пакет, предоставляющий tshark."
    fi
  fi

  log "Пакет для tshark: ${provider}"
  install_dnf_package "${provider}" || die "Не удалось установить пакет для tshark: ${provider}"

  command_exists tshark || die "Пакет ${provider} установлен, но команда tshark не найдена."
  tshark --version | head -n 1
}

print_summary() {
  cat <<'EOF'

Проверка установленных бинарников:
EOF

  local item
  for item in hyprlock hyprpaper cliphist yazi qt6ct tshark termshark btm; do
    if command_exists "${item}"; then
      printf '  %-10s %s\n' "${item}" "$(command -v "${item}")"
    else
      printf '  %-10s %s\n' "${item}" "не найден в PATH"
    fi
  done

  cat <<'EOF'

Команды проверки версий:
  hyprlock --version
  hyprpaper --version
  cliphist --help
  yazi --version
  qt6ct --version
  tshark --version
  termshark --version
  btm --version

Если yazi/termshark/btm установлены через cargo/go, убедись, что в PATH есть:
  $HOME/.cargo/bin
  $HOME/go/bin
EOF
}

main() {
  check_sudo
  check_fedora
  mkdir -p "${BUILD_DIR}"

  install_qt6ct
  install_tshark
  build_hyprlock
  build_hyprpaper
  install_cliphist
  install_yazi
  install_termshark
  install_bottom

  print_summary
}

main "$@"
