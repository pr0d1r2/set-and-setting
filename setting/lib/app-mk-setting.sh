#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-mk-setting.sh -- runnable installer for mkSetting (C9).
# Materializes unified configs (.markdownlint.yml, .yamllint.yml) into CWD.
# Env in: SETTING_SRC (path to materialized config bundle)
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
    echo "Usage: mkSetting [--help] [--list] [--dry-run]"
    echo ""
    echo "Materialize unified configs into CWD."
    echo "Always overwrites existing files."
    exit 0
fi

if [ "${1:-}" = "--list" ]; then
    echo "Materialized configs:"
    find -L "$SETTING_SRC" -type f | sort | while read -r f; do
        echo "  ${f#"$SETTING_SRC/"}"
    done
    exit 0
fi

if [ "${1:-}" = "--dry-run" ]; then
    echo "Would materialize into CWD:"
    find -L "$SETTING_SRC" -type f | sort | while read -r f; do
        echo "  ${f#"$SETTING_SRC/"}"
    done
    exit 0
fi

find -L "$SETTING_SRC" -type f | sort | while read -r f; do
    rel="${f#"$SETTING_SRC/"}"
    mkdir -p "$(dirname "$rel")"
    cp -f "$f" "$rel"
done
echo "synced setting -> ."
