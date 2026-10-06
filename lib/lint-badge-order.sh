#!/usr/bin/env bash
# Enforce the README badge convention and require CI when CI is present.
set -euo pipefail

for path in "$@"; do
  case "$path" in
    */README.md | README.md)
      root=${path%/README.md}
      [ "$root" = "$path" ] && root=.
      ci=0
      for workflow in "$root"/.github/workflows/*; do
        [ -f "$workflow" ] && ci=1
      done
      [ -f "$root/ci.yml" ] && ci=1
      awk -v path="$path" -v ci="$ci" '
        BEGIN { badges = 0; first_line = 0; bad = 0; ci_badge = 0; previous = 0 }
        {
          if ($0 !~ /\[!\[/) next
          if ($0 !~ /\[!\[[^]]*\]\([^)]*\)\]\([^)]*\)/) {
            printf "%s:%d: badge is missing a link target; expected CI, license, NixOS, then project-specific badges on one line\n", path, FNR
            bad = 1
            next
          }
          if (badges == 0) first_line = FNR
          if (FNR != first_line) {
            printf "%s:%d: badges must be on one line; expected CI, license, NixOS, then project-specific badges on one line\n", path, FNR
            bad = 1
          }
          rest = $0
          while (match(rest, /\[!\[[^]]*\]\([^)]*\)\]\([^)]*\)/)) {
            badge = substr(rest, RSTART, RLENGTH)
            alt = badge
            sub(/^\[!\[/, "", alt)
            sub(/\].*$/, "", alt)
            lower = tolower(alt)
            rank = 4
            if (lower == "ci" || lower == "pipeline status") { rank = 1; ci_badge = 1 }
            else if (lower ~ /^license([:]|$)/) rank = 2
            else if (lower ~ /^nixos[[:space:]]/) rank = 3
            if (rank < previous) {
              printf "%s:%d: badges are out of order; expected CI, license, NixOS, then project-specific badges on one line\n", path, FNR
              bad = 1
            }
            previous = rank
            badges++
            rest = substr(rest, RSTART + RLENGTH)
          }
        }
        END {
          if (ci && !ci_badge) {
            printf "%s:1: CI exists but README has no CI badge; expected first badge: [![CI](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)\n", path
            bad = 1
          }
          if (bad) {
            printf "%s:1: corrected badge order: CI, license, NixOS, then project-specific badges, all on one line\n", path
            exit 1
          }
        }
      ' "$path"
      ;;
  esac
done
