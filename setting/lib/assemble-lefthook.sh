#!/usr/bin/env bash
# assemble-lefthook.sh -- assemble lefthook.yml from integration fragments.
# Merges pre-commit + pre-push sections from selected fragment files into
# a single lefthook.yml. Fragment order is deterministic.
# No remotes: block -- all linters are pinned flake checks (#102 FLIP).
# Env in: FRAGMENTS_DIR, out
#   FRAGMENTS (optional): space-separated fragment names to include.
#     Defaults to all: "base nix shell ascii markdown yaml set".
# shellcheck disable=SC2154
set -euo pipefail

mkdir -p "$out"

ordered="${FRAGMENTS:-base nix shell ascii markdown yaml set}"

{
  printf '%s\n' '---'

  has_precommit=0
  for name in $ordered; do
    if grep -q '^pre-commit:' "$FRAGMENTS_DIR/$name.yml"; then
      if [ "$has_precommit" -eq 0 ]; then
        printf '\n%s\n' 'pre-commit:'
        printf '%s\n' '  commands:'
        has_precommit=1
      fi
      awk '/^pre-commit:/{s=1;next} s&&/^  commands:/{c=1;next} /^pre-push:/{s=0;c=0} c&&/^[a-z]/{s=0;c=0} c&&NF{print}' \
        "$FRAGMENTS_DIR/$name.yml"
    fi
  done
  if [ -f "lefthook-repo.yml" ]; then
    if grep -q '^pre-commit:' "lefthook-repo.yml"; then
      if [ "$has_precommit" -eq 0 ]; then
        printf '\n%s\n' 'pre-commit:'
        printf '%s\n' '  commands:'
        has_precommit=1
      fi
      awk '/^pre-commit:/{s=1;next} s&&/^  commands:/{c=1;next} /^pre-push:/{s=0;c=0} c&&/^[a-z]/{s=0;c=0} c&&NF{print}' \
        "lefthook-repo.yml"
    fi
  fi

  has_prepush=0
  for name in $ordered; do
    if grep -q '^pre-push:' "$FRAGMENTS_DIR/$name.yml"; then
      if [ "$has_prepush" -eq 0 ]; then
        printf '\n%s\n' 'pre-push:'
        printf '%s\n' '  commands:'
        has_prepush=1
      fi
      awk '/^pre-push:/{s=1;next} s&&/^  commands:/{c=1;next} s&&/^[a-z]/{s=0;c=0} c&&NF{print}' \
        "$FRAGMENTS_DIR/$name.yml"
    fi
  done
  if [ -f "lefthook-repo.yml" ]; then
    if grep -q '^pre-push:' "lefthook-repo.yml"; then
      if [ "$has_prepush" -eq 0 ]; then
        printf '\n%s\n' 'pre-push:'
        printf '%s\n' '  commands:'
        has_prepush=1
      fi
      awk '/^pre-push:/{s=1;next} s&&/^  commands:/{c=1;next} s&&/^[a-z]/{s=0;c=0} c&&NF{print}' \
        "lefthook-repo.yml"
    fi
  fi
} >"$out/lefthook.yml"
