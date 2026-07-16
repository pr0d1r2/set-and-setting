#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-seed.sh -- emit the committed minimum for a leaf consumer repo (#95).
# Seeds: thin flake.nix, .gitignore, and CI caller workflow.
# Skips files that already exist (repo-owned after seeding).
# Env in: SEED_SRC (path to leaf-seed derivation)
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
  echo "Usage: seed [--help] [--list] [--dry-run]"
  echo ""
  echo "Emit the committed minimum for a leaf consumer repo."
  echo "Seeds: flake.nix, .gitignore, .github/workflows/ci.yml"
  echo ""
  echo "Skips files that already exist. After seeding, run:"
  echo "  nix flake update"
  echo "  nix develop -c lefthook install"
  exit 0
fi

if [ "${1:-}" = "--list" ]; then
  echo "Seed files:"
  find -L "$SEED_SRC" -type f | sort | while read -r f; do
    rel="${f#"$SEED_SRC/"}"
    echo "  $rel"
  done
  exit 0
fi

if [ "${1:-}" = "--dry-run" ]; then
  echo "Would seed into CWD (skip existing):"
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
  echo "seeded: $rel"
done
echo "seed complete -> ."
