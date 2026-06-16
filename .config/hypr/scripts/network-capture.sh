#!/usr/bin/env bash
set -euo pipefail

mode="${1:-tshark}"

case "${mode}" in
  tshark)
    printf "\033[38;2;127;182;201mNetwork workspace: tshark TCP/UDP capture\033[0m\n"
    printf "Command: tshark -i any -f \"tcp or udp\" -l -c 300\n\n"
    printf "No sudo is run here. If capture permission fails, configure dumpcap permissions or add your user to the wireshark group.\n\n"

    if command -v tshark >/dev/null; then
      tshark -i any -f "tcp or udp" -l -c 300
    else
      printf "tshark is not installed.\n"
    fi

    printf "\nCapture finished. Press Enter to keep a shell here, or close the window.\n"
    read -r _
    exec "${SHELL}" -l
    ;;
  termshark)
    printf "\033[38;2;184;163;111mtermshark can use more RAM than raw tshark.\033[0m\n"
    printf "Prefer selecting a specific interface for longer inspections.\n"
    printf "No sudo is run here. If capture permission fails, configure dumpcap permissions or the wireshark group.\n\n"

    if command -v termshark >/dev/null; then
      exec termshark -i any -f "tcp or udp"
    fi

    printf "termshark is not installed.\n"
    exec "${SHELL}" -l
    ;;
  *)
    printf "Usage: %s [tshark|termshark]\n" "$0" >&2
    exit 2
    ;;
esac
