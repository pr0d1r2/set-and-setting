#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-mk-setting.sh -- runnable installer for mkSetting (C9).
# Materializes unified configs (.markdownlint.yml, .yamllint.yml,
# lefthook.yml) into CWD. lefthook.yml is assembled from detected
# repo content. When a parallel-change migration is active (#281),
# also emits lefthook-migration.yml (advisory overlay).
# Env in: SETTING_SRC (path to materialized config bundle),
#         FRAGMENTS_DIR, ASSEMBLE_SCRIPT, DETECT_SCRIPT, COVERAGE_SCRIPT,
#         CHECKS_UNIVERSE
#         MIGRATION_OVERLAY_DIR (optional): path to migration fragment files
#         MIGRATION_OVERLAY_SCRIPT (optional): overlay assembler script
#         MIGRATION_SKIPS (optional): commands to skip in main config
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
  echo "Usage: mkSetting [--help] [--list] [--dry-run]"
  echo ""
  echo "Materialize unified configs into CWD."
  echo "Always overwrites existing files."
  echo "lefthook.yml is assembled from detected repo content."
  echo "When a migration is active, also emits lefthook-migration.yml."
  exit 0
fi

detected="$(bash "$DETECT_SCRIPT")"

# Determine if a migration overlay is active
_has_migration=""
if [ -n "${MIGRATION_OVERLAY_DIR:-}" ] && [ -d "${MIGRATION_OVERLAY_DIR:-}" ]; then
  _migration_count="$(find -L "$MIGRATION_OVERLAY_DIR" -name '*.yml' -type f 2>/dev/null | wc -l)"
  if [ "$_migration_count" -gt 0 ]; then
    _has_migration=1
  fi
fi

assemble_out="$(mktemp -d)"
trap 'rm -rf "$assemble_out"' EXIT

FRAGMENTS="$detected" \
  MIGRATION_SKIPS="${MIGRATION_SKIPS:-}" \
  MIGRATION_HAS_OVERLAY="${_has_migration}" \
  out="$assemble_out" \
  bash "$ASSEMBLE_SCRIPT"

# Assemble migration overlay when active
if [ -n "$_has_migration" ] && [ -n "${MIGRATION_OVERLAY_SCRIPT:-}" ]; then
  MIGRATION_OVERLAY_DIR="$MIGRATION_OVERLAY_DIR" \
    FRAGMENTS="$detected" \
    out="$assemble_out" \
    bash "$MIGRATION_OVERLAY_SCRIPT"
fi

if [ "${1:-}" = "--list" ]; then
  echo "Materialized configs:"
  find -L "$SETTING_SRC" -type f | sort | while read -r f; do
    echo "  ${f#"$SETTING_SRC/"}"
  done
  echo "  lefthook.yml (content-aware: $detected)"
  if [ -n "$_has_migration" ]; then
    echo "  lefthook-migration.yml (migration overlay, advisory)"
  fi
  exit 0
fi

if [ "${1:-}" = "--dry-run" ]; then
  echo "Would materialize into CWD:"
  echo "Detected fragments: $detected"
  find -L "$SETTING_SRC" -type f | sort | while read -r f; do
    echo "  ${f#"$SETTING_SRC/"}"
  done
  echo "  lefthook.yml (content-aware: $detected)"
  if [ -n "$_has_migration" ]; then
    echo "  lefthook-migration.yml (migration overlay, advisory)"
    echo "  Migration skips: ${MIGRATION_SKIPS:-none}"
  fi
  exit 0
fi

# Model-aware refresh (#147). A tracked vendored-remotes configuration cannot
# be replaced by leaf materialization alone: migration must move its coverage
# into checksFor in the same change. Refuse before copying any files.
if [ -f lefthook.yml ] && grep -q '^remotes:' lefthook.yml &&
  { [ ! -f flake.nix ] || ! bash "$COVERAGE_SCRIPT" --has-active-checks-for flake.nix; }; then
  echo "COVERAGE-FAIL: vendored lefthook remotes require migration"
  echo "  model: vendored (lefthook remotes present, flake checksFor absent)"
  echo "  resolution: run nix run github:pr0d1r2/set-and-setting#migrate first"
  exit 1
fi

# Backstop every overwrite, including custom local commands: AFTER must cover
# BEFORE via materialized lefthook commands plus referenced flake checksFor.
if [ -f lefthook.yml ]; then
  BEFORE_LEFTHOOK="lefthook.yml" \
    AFTER_LEFTHOOK="$assemble_out/lefthook.yml" \
    FLAKE_FILE="flake.nix" \
    CHECKS_UNIVERSE="${CHECKS_UNIVERSE:-}" \
    bash "$COVERAGE_SCRIPT"
fi

find -L "$SETTING_SRC" -type f | sort | while read -r f; do
  rel="${f#"$SETTING_SRC/"}"
  mkdir -p "$(dirname "$rel")"
  cp -f "$f" "$rel"
done

cp -f "$assemble_out/lefthook.yml" "lefthook.yml"

# Copy migration overlay when active
if [ -n "$_has_migration" ] && [ -f "$assemble_out/lefthook-migration.yml" ]; then
  cp -f "$assemble_out/lefthook-migration.yml" "lefthook-migration.yml"
  echo "synced setting -> . (lefthook: $detected, migration overlay: active)"
else
  echo "synced setting -> . (lefthook: $detected)"
fi
