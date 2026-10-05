#!/usr/bin/env bash
# Report duplicate §B and §T identifiers in ledger files.
set -euo pipefail

for path in "$@"; do
  awk -v path="$path" '
    /^\|[[:space:]]*[BT][0-9]+[[:space:]]*\|/ {
      id = $2
      gsub(/[[:space:]]/, "", id)
      if (seen[id]++) {
        printf "%s:%d: duplicate ledger id %s\n", path, NR, id
        finding = 1
      }
    }
    END { if (finding) exit 1 }
  ' "$path"
done
