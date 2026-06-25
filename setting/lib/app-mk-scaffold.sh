#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-mk-scaffold.sh -- runnable installer for mkScaffold (C9).
# Scaffolds repo infrastructure files into CWD (skip-if-exists):
# flake.nix, lefthook.yml, .github/workflows/ci.yml.
# Env in: SCAFFOLD_SRC (path to scaffold bundle)
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
    echo "Usage: mkScaffold [--help] [--list] [--dry-run]"
    echo ""
    echo "Scaffold repo infrastructure files into CWD."
    echo "Emits flake.nix (nix-lefthook devShell), lefthook.yml"
    echo "(assembled from integration fragments), and CI workflow."
    echo "Skips files that already exist (repo-owned after scaffolding)."
    echo ""
    echo "Note: green CI also requires a CACHIX_AUTH_TOKEN repo secret."
    exit 0
fi

if [ "${1:-}" = "--list" ]; then
    echo "Scaffold files:"
    find -L "$SCAFFOLD_SRC" -type f | sort | while read -r f; do
        echo "  ${f#"$SCAFFOLD_SRC/"}"
    done
    exit 0
fi

if [ "${1:-}" = "--dry-run" ]; then
    echo "Would scaffold into CWD (skip existing):"
    find -L "$SCAFFOLD_SRC" -type f | sort | while read -r f; do
        rel="${f#"$SCAFFOLD_SRC/"}"
        if [ -e "$rel" ]; then
            echo "  $rel (skip -- exists)"
        else
            echo "  $rel"
        fi
    done
    exit 0
fi

find -L "$SCAFFOLD_SRC" -type f | sort | while read -r f; do
    rel="${f#"$SCAFFOLD_SRC/"}"
    if [ -e "$rel" ]; then
        continue
    fi
    mkdir -p "$(dirname "$rel")"
    cp "$f" "$rel"
    echo "scaffolded: $rel"
done
echo "synced scaffold -> ."
