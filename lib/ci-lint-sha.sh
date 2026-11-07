#!/usr/bin/env bash
set -euo pipefail

status=0
for path in "$@"; do
  case "$path" in
    *.yml | *.yaml)
      awk -v path="$path" '
        /^[[:space:]]*(-[[:space:]]*)?uses:[[:space:]]*/ {
          value = $0
          sub(/^[[:space:]]*(-[[:space:]]*)?uses:[[:space:]]*/, "", value)
          sub(/[[:space:]]+#.*$/, "", value)
          sub(/^"/, "", value)
          sub(/"$/, "", value)
          sub(/^\047/, "", value)
          sub(/\047$/, "", value)
          if (value ~ /^\.\//) next
          reference = value
          sub(/^.*@/, "", reference)
          if (reference !~ /^[[:xdigit:]]{40}$/) {
            printf "%s:%d: uses reference must be a full 40-character commit SHA; resolve with: git ls-remote https://github.com/owner/repo refs/heads/main\n", path, FNR
            found = 1
          }
        }
        END { if (found) exit 1 }
      ' "$path" || status=1
      ;;
  esac
done
exit "$status"
