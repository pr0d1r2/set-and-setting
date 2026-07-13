#!/usr/bin/env bash
# auto-update.sh -- T8/C7: auto-update for consumer repos. Updates the
# set-and-setting flake input, syncs set and setting, commits flake.lock.
# Designed for CI (GitHub Actions reusable workflow) or local use.
set -euo pipefail

input="set-and-setting"
dry_run=0
do_commit=1

while [ $# -gt 0 ]; do
  case "$1" in
    --help)
      echo "Usage: auto-update [--help] [--dry-run] [--no-commit] [--input NAME]"
      echo ""
      echo "Update set-and-setting to latest upstream, sync, and commit."
      echo ""
      echo "Options:"
      echo "  --help        Show this help and exit"
      echo "  --dry-run     Show what would change without writing"
      echo "  --no-commit   Update and sync but do not commit"
      echo "  --input NAME  Flake input name (default: set-and-setting)"
      exit 0
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --no-commit)
      do_commit=0
      shift
      ;;
    --input)
      shift
      if [ $# -eq 0 ]; then
        echo "error: --input requires a name"
        exit 1
      fi
      input="$1"
      shift
      ;;
    *)
      echo "error: unknown option '$1'"
      echo "Run 'auto-update --help' for usage."
      exit 1
      ;;
  esac
done

if [ ! -d .git ]; then
  echo "error: not a git repository"
  exit 1
fi
if [ ! -f flake.lock ]; then
  echo "error: no flake.lock found"
  exit 1
fi
if ! grep -q "\"$input\"" flake.lock; then
  echo "error: flake input '$input' not found in flake.lock"
  exit 1
fi

if [ "$dry_run" -eq 1 ]; then
  echo "Would update flake input: $input"
  echo "Would sync set and setting after update"
  [ "$do_commit" -eq 1 ] && echo "Would commit flake.lock"
  exit 0
fi

echo "Updating flake input: $input"
nix flake update "$input"

if git diff --quiet flake.lock; then
  echo "no update: $input is already at latest"
  exit 0
fi

nix flake check --no-build

# Sync set: build packages.set and run its sync-set script.
if set_pkg="$(nix build .#set --print-out-paths --no-link 2>/dev/null)"; then
  "$set_pkg/bin/sync-set" .
fi

# Sync setting: build packages.setting and run its sync-setting script.
if setting_pkg="$(nix build .#setting --print-out-paths --no-link 2>/dev/null)"; then
  "$setting_pkg/bin/sync-setting" .
fi

if [ "$do_commit" -eq 1 ]; then
  git add flake.lock
  git commit -m "chore: update $input"
fi
