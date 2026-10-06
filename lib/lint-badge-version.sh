#!/usr/bin/env bash
set -euo pipefail
flake_path=$1
readme_path=$2
lock_path=${3:-}
awk -v flake_path="$flake_path" -v readme_path="$readme_path" -v lock_path="$lock_path" '
BEGIN { channel = ""; badge = ""; badge_line = 0 }
FILENAME == flake_path {
  if ($0 ~ /nixpkgs\.url[[:space:]]*=[[:space:]]*"github:NixOS\/nixpkgs\/nixos-[^"]+"/) {
    channel = $0; sub(/^.*github:NixOS\/nixpkgs\/nixos-/, "", channel); sub(/".*$/, "", channel)
  }; next
}
FILENAME == readme_path {
  if ($0 ~ /\[!\[NixOS[[:space:]]+[0-9.]+\]\(https:\/\/img\.shields\.io\/badge\/NixOS-[0-9.]+-blue\.svg/) {
    match($0, /NixOS-[0-9.]+-blue\.svg/); badge = substr($0, RSTART + 6, RLENGTH - 15); badge_line = FNR
  }
}
FILENAME == lock_path {
  if (channel == "" && $0 ~ /"ref"[[:space:]]*:[[:space:]]*"nixos-[0-9]+\.[0-9]+"/) {
    channel = $0; sub(/^.*"nixos-/, "", channel); sub(/".*$/, "", channel)
  }
}
END {
  if (channel == "") { printf "%s:1: NixOS badge channel is unknown (flake does not pin a named nixpkgs channel); expected badge line: [![NixOS VERSION](https://img.shields.io/badge/NixOS-VERSION-blue.svg?logo=nixos)](https://nixos.org)\n", readme_path; exit 1 }
  if (badge == "") { printf "%s:1: NixOS badge version is unknown (no versioned badge found); expected nixpkgs channel: %s\n", readme_path, channel; exit 1 }
  if (channel != badge) { printf "%s:%d: NixOS badge version %s does not match flake nixpkgs channel %s; expected badge line: [![NixOS %s](https://img.shields.io/badge/NixOS-%s-blue.svg?logo=nixos)](https://nixos.org)\n", readme_path, badge_line, badge, channel, channel, channel; exit 1 }
}
' "$flake_path" "$readme_path" "$lock_path"
