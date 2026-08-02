#!/usr/bin/env bash
set -euo pipefail

if [ -z "${FLAKE_MANIFEST_STRICTNESS:-}" ]; then
  FLAKE_MANIFEST_STRICTNESS="$(get-flake-manifest-strictness)"
  export FLAKE_MANIFEST_STRICTNESS
fi

exec lefthook-flake-manifest "${1:-flake.nix}"
