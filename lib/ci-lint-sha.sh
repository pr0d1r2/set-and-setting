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
          # The leaf seed deliberately follows the reusable workflow branch
          # so consumers receive updates without editing their scaffolded CI.
          # Keep this single canonical caller compatible with the SHA hook;
          # every action reference remains subject to the immutable-ref rule.
          canonical_leaf_guardrails = value == "pr0d1r2/set-and-setting/.github/workflows/guardrails.yml@main"
          if (!canonical_leaf_guardrails && reference !~ /^[[:xdigit:]]{40}$/) {
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
