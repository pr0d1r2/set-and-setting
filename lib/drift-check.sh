#!/usr/bin/env bash
# Generic drift comparator, extracted from the mk-*-drift-check builders
# (nix/modularity: no embedded shell in nix files). Diffs EXPECTED vs
# ACTUAL over REL_PATHS (space-separated relative paths, files or dirs).
# Exits 1 on any drift or missing path and prints SYNC_HINT; exits 0 with
# "no drift" on a full match. Layout-agnostic: callers pass the paths.
set -euo pipefail

read -ra paths <<<"${REL_PATHS:-}"
drift=0

for rel in "${paths[@]:-}"; do
  [ -n "$rel" ] || continue
  if [ ! -e "$EXPECTED/$rel" ]; then
    echo "UNKNOWN: canonical path is absent: $rel -- $SYNC_HINT"
    drift=1
    continue
  fi
  if [ ! -e "$ACTUAL/$rel" ]; then
    echo "MISSING: $rel -- $SYNC_HINT"
    drift=1
  else
    diff -rq "$EXPECTED/$rel" "$ACTUAL/$rel" || drift=1
  fi
done

if [ "$drift" -ne 0 ]; then
  echo "DRIFT DETECTED -- $SYNC_HINT"
  exit 1
fi

echo "no drift"
