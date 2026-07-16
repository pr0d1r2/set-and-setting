#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-mk-scaffold.sh -- runnable installer for mkScaffold (C9).
# Scaffolds repo infrastructure files into CWD (skip-if-exists).
# Constructs lefthook.yml from detected repo content (content-aware).
# Env in: SCAFFOLD_SRC (path to scaffold bundle),
#         FRAGMENTS_DIR, ASSEMBLE_SCRIPT, DETECT_SCRIPT
set -euo pipefail

detected="$(bash "$DETECT_SCRIPT")"

assemble_out="$(mktemp -d)"
trap 'rm -rf "$assemble_out"' EXIT
FRAGMENTS="$detected" out="$assemble_out" bash "$ASSEMBLE_SCRIPT"

if [ "${1:-}" = "--help" ]; then
  echo "Usage: mkScaffold [--help] [--list] [--dry-run]"
  echo ""
  echo "Scaffold repo infrastructure files into CWD."
  echo "Emits flake.nix (nix-lefthook devShell), lefthook.yml"
  echo "(assembled from detected repo content), and CI workflow."
  echo "Skips files that already exist (repo-owned after scaffolding)."
  echo ""
  exit 0
fi

if [ "${1:-}" = "--list" ]; then
  echo "Scaffold files:"
  find -L "$SCAFFOLD_SRC" -type f | sort | while read -r f; do
    rel="${f#"$SCAFFOLD_SRC/"}"
    [ "$rel" = "lefthook.yml" ] && continue
    echo "  $rel"
  done
  echo "  lefthook.yml (content-aware: $detected)"
  exit 0
fi

if [ "${1:-}" = "--dry-run" ]; then
  echo "Would scaffold into CWD (skip existing):"
  echo "Detected fragments: $detected"
  find -L "$SCAFFOLD_SRC" -type f | sort | while read -r f; do
    rel="${f#"$SCAFFOLD_SRC/"}"
    [ "$rel" = "lefthook.yml" ] && continue
    if [ -e "$rel" ]; then
      echo "  $rel (skip -- exists)"
    else
      echo "  $rel"
    fi
  done
  if [ -e "lefthook.yml" ]; then
    echo "  lefthook.yml (skip -- exists)"
  else
    echo "  lefthook.yml (content-aware: $detected)"
  fi
  exit 0
fi

find -L "$SCAFFOLD_SRC" -type f | sort | while read -r f; do
  rel="${f#"$SCAFFOLD_SRC/"}"
  [ "$rel" = "lefthook.yml" ] && continue
  if [ -e "$rel" ]; then
    continue
  fi
  mkdir -p "$(dirname "$rel")"
  cp "$f" "$rel"
  echo "scaffolded: $rel"
done

if [ ! -e "lefthook.yml" ]; then
  cp "$assemble_out/lefthook.yml" "lefthook.yml"
  echo "scaffolded: lefthook.yml (detected: $detected)"
fi
echo "synced scaffold -> ."
