#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-confirm.sh -- consumer-side post-materialization acceptance suite (#94).
# Runs against the INVOKING repo (CWD) to prove materialization succeeded.
# Env in: FRAGMENTS_DIR, ASSEMBLE_SCRIPT, DETECT_SCRIPT, SETTING_SRC,
#         CONFIRM_SCRIPT, CONFIRM_REV
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
    echo "Usage: confirm [--help] [--dry-run]"
    echo ""
    echo "Post-materialization acceptance suite."
    echo "Verifies: completeness, fidelity, coherence, executability,"
    echo "          idempotency, binding-integrity, no-drift."
    echo ""
    echo "Run after 'mkSetting' to confirm materialization is correct."
    exit 0
fi

if [ "${1:-}" = "--dry-run" ]; then
    export CONFIRM_DRY_RUN="1"
fi

bash "$CONFIRM_SCRIPT"
