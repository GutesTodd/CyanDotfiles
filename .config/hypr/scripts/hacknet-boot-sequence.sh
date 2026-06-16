#!/usr/bin/env bash
set -euo pipefail

type_line() {
  local text="$1"
  local delay="${2:-0.018}"
  local i=0

  while (( i < ${#text} )); do
    printf "%s" "${text:i:1}"
    sleep "${delay}"
    i=$((i + 1))
  done
  printf "\n"
}

clear
printf "\033[38;2;127;182;201m"

type_line "Connecting..."
sleep 0.12
type_line "Initializing subsystems..."
sleep 0.12
type_line "Loading workspace..."
sleep 0.16
printf "\033[38;2;139;191;159m"
type_line "[ SYSTEM READY ]" 0.014

printf "\033[0m"
sleep 0.35
