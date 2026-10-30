#!/usr/bin/env bash
set -euo pipefail
status=0
for path in "$@"; do
  case "$path" in
    .github/workflows/*.yml)
      awk -v path="$path" '
        /^[[:space:]]*(-[[:space:]]*)?uses:[[:space:]]*/ {
          value = $0; sub(/^[^:]*:[[:space:]]*/, "", value); sub(/[[:space:]]+#.*$/, "", value)
          if (value ~ /^\.\//) next
          if (value !~ /^[^@]+@[[:xdigit:]]{40}$/) {
            split(value, parts, "@")
            printf "%s:%d: uses reference must be a full 40-character commit SHA; resolve with `git ls-remote https://github.com/%s refs/heads/main`\n", path, FNR, parts[1]
            found = 1
          }
        }
        END { if (found) exit 1 }
      ' "$path" || status=1
      ;;
  esac
done
exit "$status"
