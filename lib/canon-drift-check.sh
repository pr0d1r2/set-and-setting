#!/usr/bin/env bash
# The canonical-paths half of `mk-canon-drift-check.nix`, extracted so that nix
# file carries no shell (the repo's own `nix-no-embedded-shell` rule).
#
# Two steps, unchanged in behaviour: every pinned canonical path must EXIST in
# the expected tree — an absent one is UNKNOWN rather than drift, because a
# comparison against something that is not there proves nothing — and then the
# generic comparator runs.
#
# From the derivation: EXPECTED · ACTUAL · REL_PATHS · SYNC_HINT.

# shellcheck disable=SC2154 # `out` is nix's, exported by the derivation
set -euo pipefail

read -ra rels <<<"${REL_PATHS:-}"
for rel in "${rels[@]:-}"; do
  [ -n "$rel" ] || continue
  if [ ! -e "$EXPECTED/$rel" ]; then
    echo "UNKNOWN: pinned canonical path is absent: $rel -- ${SYNC_HINT:-}"
    exit 1
  fi
done

bash "$DRIFT_CHECK_SCRIPT"
touch "$out"
