#!/usr/bin/env bash
# assemble-migration-overlay.sh -- emit lefthook-migration.yml with advisory commands.
# Merges pre-commit + pre-push sections from migration fragment files into
# a single lefthook-migration.yml. Commands are advisory (non-blocking):
# each run: line is appended with "; true" so failures never block CI.
# Fragment order is deterministic (same as assemble-lefthook.sh).
# Env in: MIGRATION_OVERLAY_DIR, out.
#   FRAGMENTS (optional): space-separated fragment names to include.
# shellcheck disable=SC2154
set -euo pipefail

mkdir -p "$out"

overlay_dir="${MIGRATION_OVERLAY_DIR}"
ordered="${FRAGMENTS:-base actions nix shell ruby rubocop rspec reek brakeman bundle-audit ascii markdown yaml set}"

{
  printf '%s\n' '---'
  printf '%s\n' '# Migration overlay (#281): advisory (non-blocking) commands.'
  printf '%s\n' '# Delete this file to roll back the migration.'

  has_precommit=0
  for name in $ordered; do
    if [ -f "$overlay_dir/$name.yml" ] && grep -q '^pre-commit:' "$overlay_dir/$name.yml"; then
      if [ "$has_precommit" -eq 0 ]; then
        printf '\n%s\n' 'pre-commit:'
        printf '%s\n' '  commands:'
        has_precommit=1
      fi
      awk '/^pre-commit:/{s=1;next} s&&/^  commands:/{c=1;next} /^pre-push:/{s=0;c=0} c&&/^[a-z]/{s=0;c=0} c&&NF{
        if (/^      run: /) { $0 = $0 "; true" }
        print
      }' "$overlay_dir/$name.yml"
    fi
  done

  has_prepush=0
  for name in $ordered; do
    if [ -f "$overlay_dir/$name.yml" ] && grep -q '^pre-push:' "$overlay_dir/$name.yml"; then
      if [ "$has_prepush" -eq 0 ]; then
        printf '\n%s\n' 'pre-push:'
        printf '%s\n' '  commands:'
        has_prepush=1
      fi
      awk '/^pre-push:/{s=1;next} s&&/^  commands:/{c=1;next} s&&/^[a-z]/{s=0;c=0} c&&NF{
        if (/^      run: /) { $0 = $0 "; true" }
        print
      }' "$overlay_dir/$name.yml"
    fi
  done
} >"$out/lefthook-migration.yml"
