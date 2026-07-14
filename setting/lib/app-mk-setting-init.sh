#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-mk-setting-init.sh -- runnable installer for mkSetting-init (C9).
# Seeds repo-specific starter files into CWD (skip-if-exists).
# Env in: SEED_SRC (path to seed bundle)
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
    echo "Usage: mkSetting-init [--help] [--list] [--dry-run]"
    echo ""
    echo "Scaffold repo-specific starter files into CWD."
    echo "Skips files that already exist (repo-owned after scaffolding)."
    exit 0
fi

if [ "${1:-}" = "--list" ]; then
    echo "Seed files:"
    find -L "$SEED_SRC" -type f | sort | while read -r f; do
        echo "  ${f#"$SEED_SRC/"}"
    done
    exit 0
fi

if [ "${1:-}" = "--dry-run" ]; then
    echo "Would scaffold into CWD (skip existing):"
    find -L "$SEED_SRC" -type f | sort | while read -r f; do
        rel="${f#"$SEED_SRC/"}"
        if [ -e "$rel" ]; then
            echo "  $rel (skip -- exists)"
        else
            echo "  $rel"
        fi
    done
    exit 0
fi

find -L "$SEED_SRC" -type f | sort | while read -r f; do
    rel="${f#"$SEED_SRC/"}"
    if [ -e "$rel" ]; then
        continue
    fi
    mkdir -p "$(dirname "$rel")"
    cp "$f" "$rel"
    echo "scaffolded: $rel"
done
echo "synced setting-init -> ."
