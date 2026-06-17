#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-bootstrap.sh -- combined installer: mkSet core + mkSetting +
# mkSetting-init (C9). Equivalent to running all three in sequence.
# Env in: MKSET_APP, MKSETTING_APP, MKSETTING_INIT_APP
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
    echo "Usage: bootstrap [--help] [--dry-run]"
    echo ""
    echo "Combined installer: mkSet (core) + mkSetting + mkSetting-init."
    echo "Equivalent to running all three in sequence."
    exit 0
fi

args=()
[ "${1:-}" = "--dry-run" ] && args+=("--dry-run")

"$MKSET_APP" "${args[@]+"${args[@]}"}"
"$MKSETTING_APP" "${args[@]+"${args[@]}"}"
"$MKSETTING_INIT_APP" "${args[@]+"${args[@]}"}"
