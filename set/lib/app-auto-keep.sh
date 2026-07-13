#!/usr/bin/env bash
# Compute the applicable skill set for `mkSet --auto` (V34/V37). Scans the
# consumer repo (git ls-files, vendored/generated excluded) and runs the
# applicability filter. Prints "relpath|reason" lines. No functions
# (sh/modularity). A non-git or empty tree leaves only core.
# Env in: SIGNALS_MANIFEST, CORE_CATEGORIES, APPLICABILITY_SCRIPT.
set -uo pipefail

tracked="$(git ls-files 2>/dev/null || true)"
filtered=""
if [ -n "$tracked" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    attr="$(git check-attr linguist-vendored linguist-generated -- "$f" 2>/dev/null || true)"
    case "$attr" in
      *": set"*) continue ;;
    esac
    filtered+="$f"$'\n'
  done <<<"$tracked"
fi

SIGNALS="${SIGNALS_MANIFEST:-}" CORE="$CORE_CATEGORIES" \
  TRACKED="$filtered" bash "$APPLICABILITY_SCRIPT"
