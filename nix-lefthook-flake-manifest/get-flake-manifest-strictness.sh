#!/usr/bin/env bash
set -euo pipefail

config="${FLAKE_MANIFEST_CONFIG:-config/lefthook/flake_manifest.yml}"

if [ ! -f "$config" ]; then
  printf '%s\n' strict
  exit 0
fi

awk '
    /^[[:space:]]*strictness:[[:space:]]*/ {
        sub(/^[[:space:]]*strictness:[[:space:]]*/, "")
        sub(/[[:space:]]*#.*/, "")
        sub(/[[:space:]]+$/, "")
        print
        found = 1
        exit
    }
    END { if (!found) print "strict" }
' "$config"
