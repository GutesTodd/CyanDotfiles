#!/usr/bin/env bash
set -euo pipefail

if ! command -v dnf >/dev/null 2>&1; then
  printf 'This dependency installer is intended for Fedora with dnf.\n' >&2
  exit 1
fi

required_packages=(
  hyprland
  hyprpaper
  hyprlock
  waybar
  kitty
  rofi-wayland
  swappy
  grim
  slurp
  grimblast
  wl-clipboard
  cliphist
  brightnessctl
  playerctl
  fastfetch
  yazi
  bottom
  jq
  git
  curl
  unzip
  tar
  NetworkManager-tui
  NetworkManager-wifi
  polkit-gnome
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

available_packages=()
missing_packages=()

package_available() {
  dnf -q repoquery --available "$1" >/dev/null 2>&1 || rpm -q "$1" >/dev/null 2>&1
}

collect_available() {
  local package
  for package in "$@"; do
    if package_available "${package}"; then
      available_packages+=("${package}")
    else
      missing_packages+=("${package}")
    fi
  done
}

collect_available "${required_packages[@]}" "${optional_packages[@]}"

if ((${#available_packages[@]} > 0)); then
  sudo dnf install -y "${available_packages[@]}"
fi

printf '\nInstalled or already available package set processed.\n'

if ((${#missing_packages[@]} > 0)); then
  printf '\nThe following packages were not found in enabled Fedora repositories:\n'
  printf '  %s\n' "${missing_packages[@]}"
  printf '\nThey are optional or repo-dependent. Install them manually if needed.\n'
fi

if command -v flatpak >/dev/null 2>&1; then
  if ! flatpak remotes --columns=name | grep -qx 'flathub'; then
    printf '\nFlathub is not configured. To add it manually:\n'
    printf '  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo\n'
  fi

  printf '\nZen Browser is used by SUPER+B. Install it manually if needed:\n'
  printf '  flatpak install flathub app.zen_browser.zen\n'
fi

cat <<'EOF'

Notes:
- tshark is provided by wireshark-cli on Fedora.
- Packet capture permissions are not configured here. Prefer adding your user
  to the wireshark group / configuring dumpcap capabilities instead of hardcoding sudo.
- Codex CLI is not installed by this script; install it using your preferred upstream method.
- split-monitor-workspaces is cloned by scripts/install.sh, not by this dependency script.
EOF
