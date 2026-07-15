#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-migrate.sh -- mechanical vendored->referenced transform (#96).
# CLI wrapper over lib/migrate.sh. Runs against the INVOKING repo (CWD).
# Env in: SEED_SRC, SETTING_SRC, FRAGMENTS_DIR, ASSEMBLE_SCRIPT,
#         DETECT_SCRIPT, CONFIRM_SCRIPT, CONFIRM_REV, MIGRATE_SCRIPT
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
  echo "Usage: migrate [--help] [--detect] [--dry-run]"
  echo ""
  echo "Mechanical, deterministic, idempotent vendored->referenced transform."
  echo "Strips vendored guardrail artifacts (flake.nix/lefthook.yml/ci.yml),"
  echo "plants the leaf seed, and gates on check-set equivalence: the new"
  echo "materialized check-set must cover every check the vendored one had."
  echo ""
  echo "  --detect    print the detected state and exit (no changes)"
  echo "  --dry-run   print the transform plan and exit (writes nothing)"
  echo ""
  echo "States:"
  echo "  referenced                 already migrated (no-op)"
  echo "  bare                       no flake, no lefthook"
  echo "  vendored                   heavy flake + tracked lefthook"
  echo "  partial-tracked-lefthook   references SNS but lefthook still tracked"
  echo "  partial-no-gitignore       references SNS but lefthook not gitignored"
  echo "  partial-no-materialization references SNS but missing checksFor/materializationFor"
  echo ""
  echo "Pre-flight checks: git repo, clean worktree, not detached HEAD."
  echo "Custom flake.nix content (extra inputs, outputs, overlays) is"
  echo "reconciled into the seed flake automatically. Un-reconcilable"
  echo "content (e.g. overlays applied to pkgs) emits a clean MIGRATE-FAIL."
  echo "Extra workflows beyond ci.yml/auto-update.yml are preserved."
  echo ""
  echo "Already-referenced repos are a no-op. Run per repo; a caller opens"
  echo "ONE mechanical PR/repo. CI then runs the full confirmator +"
  echo "'nix flake check' once 'nix flake update' has produced flake.lock."
  exit 0
fi

if [ "${1:-}" = "--detect" ]; then
  export MIGRATE_DETECT_ONLY="1"
fi

if [ "${1:-}" = "--dry-run" ]; then
  export MIGRATE_DRY_RUN="1"
fi

bash "$MIGRATE_SCRIPT"
