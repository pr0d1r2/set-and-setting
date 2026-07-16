#!/usr/bin/env bash
# check-coverage.sh -- prove a standards refresh preserves effective checks.
# Env in: BEFORE_LEFTHOOK, AFTER_LEFTHOOK, FLAKE_FILE, CHECKS_UNIVERSE.
# Effective coverage is lefthook remotes + commands, plus checksFor when the
# flake uses the referenced model.
# shellcheck disable=SC2154,SC2086
set -euo pipefail

before_checks="$(mktemp)"
after_checks="$(mktemp)"
trap 'rm -f "$before_checks" "$after_checks"' EXIT

# Command keys are scoped to commands blocks. Remote identities are derived
# from git_url basenames (nix-lefthook-foo -> foo), matching checksFor names.
awk '
  /^[A-Za-z]/                      { in_commands = 0 }
  /^  commands:[[:space:]]*$/      { in_commands = 1; next }
  /^  [A-Za-z]/ && !/^  commands:/ { in_commands = 0 }
  in_commands && /^    [A-Za-z][A-Za-z0-9_-]*:/ {
    key = $1; sub(/:.*/, "", key); print key
  }
  /git_url:[[:space:]]*/ {
    url = $0; sub(/^.*git_url:[[:space:]]*/, "", url)
    gsub(/["\047]/, "", url); sub(/[[:space:]]*#.*/, "", url)
    sub(/\/$/, "", url); sub(/\.git$/, "", url); sub(/^.*\//, "", url)
    sub(/^nix-lefthook-/, "", url)
    if (url != "") print url
  }
' "$BEFORE_LEFTHOOK" | sort -u >"$before_checks"

{
    awk '
    /^[A-Za-z]/                      { in_commands = 0 }
    /^  commands:[[:space:]]*$/      { in_commands = 1; next }
    /^  [A-Za-z]/ && !/^  commands:/ { in_commands = 0 }
    in_commands && /^    [A-Za-z][A-Za-z0-9_-]*:/ {
      key = $1; sub(/:.*/, "", key); print key
    }
    /git_url:[[:space:]]*/ {
      url = $0; sub(/^.*git_url:[[:space:]]*/, "", url)
      gsub(/["\047]/, "", url); sub(/[[:space:]]*#.*/, "", url)
      sub(/\/$/, "", url); sub(/\.git$/, "", url); sub(/^.*\//, "", url)
      sub(/^nix-lefthook-/, "", url)
      if (url != "") print url
    }
  ' "$AFTER_LEFTHOOK"
    if [ -f "$FLAKE_FILE" ] && grep -q 'checksFor' "$FLAKE_FILE"; then
        printf '%s\n' ${CHECKS_UNIVERSE:-}
    fi
} | sed '/^$/d' | sort -u >"$after_checks"

dropped="$(comm -23 "$before_checks" "$after_checks" || true)"
if [ -n "$dropped" ]; then
    echo "COVERAGE-FAIL: standards refresh would reduce effective check coverage"
    echo "  dropped: $(echo "$dropped" | tr '\n' ' ' | sed 's/ $//')"
    echo "  resolution: preserve repo-local checks or run migrate first"
    exit 1
fi

before_count="$(wc -l <"$before_checks" | tr -d ' ')"
echo "PASS: coverage -- refreshed check-set covers all $before_count existing checks"
