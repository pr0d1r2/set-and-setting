#!/usr/bin/env bash
# dep-graph-check.sh -- T9/C6: verify every flake input in flake.lock
# uses a github: URL, not git+file: or path:. Designed for nix checks
# (mk-dep-graph-check.nix) and standalone use.
set -euo pipefail

lock="${FLAKE_LOCK:-flake.lock}"
if [ ! -f "$lock" ]; then
  echo "error: $lock not found"
  exit 1
fi

non_github=$(grep '"type":' "$lock" | grep -v '"github"' || true)
if [ -n "$non_github" ]; then
  echo "FAIL: non-github flake inputs found in $lock (C6):"
  echo "$non_github"
  echo ""
  echo "All flake inputs must use github: URLs."
  echo "Switch git+file: or path: URLs to github: after pushing."
  exit 1
fi

echo "dep-graph: all inputs use github: URLs"
