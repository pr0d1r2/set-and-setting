#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-mk-setting.sh -- runnable installer for mkSetting (C9).
# Materializes unified configs (.markdownlint.yml, .yamllint.yml,
# lefthook.yml) into CWD. lefthook.yml is assembled from detected
# repo content.
# Env in: SETTING_SRC (path to materialized config bundle),
#         FRAGMENTS_DIR, ASSEMBLE_SCRIPT, DETECT_SCRIPT, COVERAGE_SCRIPT,
#         CHECKS_UNIVERSE
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
  echo "Usage: mkSetting [--help] [--list] [--dry-run]"
  echo ""
  echo "Materialize unified configs into CWD."
  echo "Always overwrites existing files."
  echo "lefthook.yml is assembled from detected repo content."
  exit 0
fi

detected="$(bash "$DETECT_SCRIPT")"

assemble_out="$(mktemp -d)"
trap 'rm -rf "$assemble_out"' EXIT
FRAGMENTS="$detected" out="$assemble_out" bash "$ASSEMBLE_SCRIPT"

if [ "${1:-}" = "--list" ]; then
  echo "Materialized configs:"
  find -L "$SETTING_SRC" -type f | sort | while read -r f; do
    echo "  ${f#"$SETTING_SRC/"}"
  done
  echo "  lefthook.yml (content-aware: $detected)"
  exit 0
fi

if [ "${1:-}" = "--dry-run" ]; then
  echo "Would materialize into CWD:"
  echo "Detected fragments: $detected"
  find -L "$SETTING_SRC" -type f | sort | while read -r f; do
    echo "  ${f#"$SETTING_SRC/"}"
  done
  echo "  lefthook.yml (content-aware: $detected)"
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
echo "synced setting -> . (lefthook: $detected)"
