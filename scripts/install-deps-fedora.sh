#!/usr/bin/env bash
set -euo pipefail

supported_fedora_versions=(43 44)

usage() {
  cat <<'EOF'
Usage: scripts/install-deps-fedora.sh [options]

Install Fedora 43/44 dependencies for these dotfiles.

Options:
  --enable-flathub   Add Flathub if it is missing.
  --install-zen      Install Zen Browser via Flatpak after ensuring Flathub.
  -h, --help         Show this help.

The script does not configure packet-capture permissions and does not install
Codex CLI. See the notes printed at the end.
EOF
}

enable_flathub=false
install_zen=false

while (($# > 0)); do
  case "$1" in
    --enable-flathub)
      enable_flathub=true
      ;;
    --install-zen)
      enable_flathub=true
      install_zen=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if ! command -v dnf >/dev/null 2>&1; then
  printf 'This dependency installer is intended for Fedora with dnf.\n' >&2
  exit 1
fi

fedora_version="$(rpm -E %fedora 2>/dev/null || true)"
supported=false
for version in "${supported_fedora_versions[@]}"; do
  if [[ "${fedora_version}" == "${version}" ]]; then
    supported=true
    break
  fi
done

if [[ "${supported}" != true ]]; then
  printf 'Warning: this script is tested for Fedora 43/44; detected Fedora %s.\n' "${fedora_version:-unknown}" >&2
  printf 'Continuing with repository availability checks.\n\n' >&2
fi

required_packages=(
  hyprland
  hyprpaper
  hyprlock
  waybar
  kitty
  rofi
  swappy
  grim
  slurp
  grimblast
  wl-clipboard
  cliphist
  brightnessctl
  playerctl
  fastfetch
  jq
  git
  curl
  unzip
  tar
  NetworkManager-tui
  NetworkManager-wifi
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk
  qt6ct
  flatpak
)

optional_packages=(
  wireshark-cli
  termshark
  jetbrains-mono-fonts
  google-noto-sans-mono-fonts
)

# Install the first available package from each group. Fedora package names can
# differ slightly between releases or enabled repositories.
alternative_groups=(
  "hyprpolkitagent polkit-gnome"
)

available_packages=()
missing_packages=()
selected_alternatives=()
missing_alternative_groups=()

package_available() {
  local package="$1"
  local arch
  arch="$(rpm -E '%{_arch}')"

  if rpm -q "${package}" >/dev/null 2>&1; then
    return 0
  fi

  dnf -q repoquery --available --qf '%{name} %{arch}' "${package}" 2>/dev/null |
    awk -v package="${package}" -v arch="${arch}" '$1 == package && ($2 == arch || $2 == "noarch") { found = 1 } END { exit found ? 0 : 1 }'
}

add_if_available() {
  local package="$1"
  if package_available "${package}"; then
    available_packages+=("${package}")
  else
    missing_packages+=("${package}")
  fi
}

select_alternative_group() {
  local group="$1"
  local package

  for package in ${group}; do
    if package_available "${package}"; then
      selected_alternatives+=("${package}")
      return 0
    fi
  done

  missing_alternative_groups+=("${group}")
}

for package in "${required_packages[@]}" "${optional_packages[@]}"; do
  add_if_available "${package}"
done

for group in "${alternative_groups[@]}"; do
  select_alternative_group "${group}"
done

packages_to_install=("${available_packages[@]}" "${selected_alternatives[@]}")

if ((${#packages_to_install[@]} > 0)); then
  sudo dnf install -y "${packages_to_install[@]}"
fi

printf '\nFedora dependency installation processed.\n'

if ((${#missing_packages[@]} > 0)); then
  printf '\nPackages not found in enabled repositories:\n'
  printf '  %s\n' "${missing_packages[@]}"
fi

if ((${#missing_alternative_groups[@]} > 0)); then
  printf '\nNo available package found for these alternative groups:\n'
  printf '  %s\n' "${missing_alternative_groups[@]}"
fi

if command -v flatpak >/dev/null 2>&1; then
  if ! flatpak remotes --columns=name | grep -qx 'flathub'; then
    if [[ "${enable_flathub}" == true ]]; then
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
      printf '\nFlathub is not configured. To add it:\n'
      printf '  %s --enable-flathub\n' "$0"
    fi
  fi

  if [[ "${install_zen}" == true ]]; then
    flatpak install -y flathub app.zen_browser.zen
  else
    printf '\nZen Browser is used by SUPER+B. To install it:\n'
    printf '  %s --install-zen\n' "$0"
  fi
fi

cat <<'EOF'

Notes:
- tshark is provided by wireshark-cli on Fedora.
- Packet capture permissions are intentionally not configured here. Prefer the
  wireshark group / dumpcap capabilities instead of hardcoded sudo in scripts.
- Codex CLI is not installed by this script; install it using your preferred
  upstream method.
- split-monitor-workspaces is cloned by scripts/install.sh, not by this script.
EOF
