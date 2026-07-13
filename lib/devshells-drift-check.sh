#!/usr/bin/env bash
# DevShell CI invariant: CI must not skip lefthook (skip-lefthook: true).
# Env: CHECK_CI_SKIP_LEFTHOOK (non-empty to enable), ACTUAL (project root).
set -euo pipefail

[ -n "${CHECK_CI_SKIP_LEFTHOOK:-}" ] || exit 0

ci_dir="$ACTUAL/.github/workflows"
if [ ! -d "$ci_dir" ]; then
  exit 0
fi

drift=0
for f in "$ci_dir"/*.yml "$ci_dir"/*.yaml; do
  [ -f "$f" ] || continue
  if grep -qE 'skip-lefthook:\s*"?true"?' "$f"; then
    echo "FAIL: $(basename "$f") has skip-lefthook: true -- CI must run lefthook"
    drift=1
  fi
done

if [ "$drift" -ne 0 ]; then
  echo "DEVSHELL DRIFT: CI workflows must not skip lefthook"
  exit 1
fi

echo "no CI skip-lefthook"
