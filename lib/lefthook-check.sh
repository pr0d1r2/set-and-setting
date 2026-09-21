#!/usr/bin/env bash
# Run one pinned linter wrapper over the filtered tree a `mk-lefthook-check`
# derivation hands it. Extracted from that builder's `runCommand` text so the
# nix file carries no shell (the repo's own `nix-no-embedded-shell` rule).
#
# From the derivation: CHECK_NAME · CHECK_FILES · CHECK_WRAPPER · CHECK_FLAG.
#
# An EMPTY tree is a pass, not a failure: `suffices` filtering can legitimately
# select nothing (a repo with no `.rb`, say), and a linter with no input has
# nothing to say about the code.

# shellcheck disable=SC2154 # `out` is nix's, exported by the derivation
set -euo pipefail

cd "$CHECK_FILES"
mapfile -t matches < <(find . -type f | LC_ALL=C sort)

if [ ${#matches[@]} -eq 0 ]; then
  echo "$CHECK_NAME: no matching files, nothing to check"
  touch "$out"
  exit 0
fi

"$CHECK_WRAPPER" "$CHECK_FLAG" "${matches[@]}"
echo "$CHECK_NAME: PASS (${#matches[@]} files)"
touch "$out"
