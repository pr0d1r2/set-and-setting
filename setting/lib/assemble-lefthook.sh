#!/usr/bin/env bash
# assemble-lefthook.sh -- assemble lefthook.yml from integration fragments.
# Merges hook sections from selected fragment files into
# a single lefthook.yml. Fragment order is deterministic.
# No remotes: block -- all linters are pinned flake checks (#102 FLIP).
# Env in: FRAGMENTS_DIR, out. Reads optional lefthook-overrides.yml from CWD.
#   FRAGMENTS (optional): space-separated fragment names to include.
#     Defaults to all Ruby and general-purpose fragments.
#   MIGRATION_SKIPS (optional): space-separated command names to mark skip:true
#     in the assembled config (expand phase of parallel-change migration #281).
#   MIGRATION_HAS_OVERLAY (optional): when "1", adds extends reference for
#     lefthook-migration.yml (the advisory overlay emitted separately).
# shellcheck disable=SC2154
set -euo pipefail

mkdir -p "$out"

ordered="${FRAGMENTS:-base actions nix shell ruby rubocop rspec reek brakeman bundle-audit ascii markdown yaml toml set}"

# Fragment lists are assembled from a base selection plus optional additions.
# Keep the first occurrence of each name: emitting a fragment twice creates
# duplicate YAML mapping keys and makes lefthook reject the materialized file.
declare -A seen_fragments=()
unique_ordered=""
for name in $ordered; do
  if [ -z "${seen_fragments[$name]+x}" ]; then
    seen_fragments[$name]=1
    unique_ordered="${unique_ordered:+$unique_ordered }$name"
  fi
done
ordered="$unique_ordered"

{
  printf '%s\n' '---'

  # Conditional extends block for overrides and migration overlay.
  # Lefthook merges extended configs after the generated commands.
  _extends=""
  if [ -f "lefthook-overrides.yml" ]; then
    _extends="${_extends}  - lefthook-overrides.yml\n"
  fi
  if [ "${MIGRATION_HAS_OVERLAY:-}" = "1" ]; then
    _extends="${_extends}  - lefthook-migration.yml\n"
  fi
  if [ -n "$_extends" ]; then
    printf '\n%s\n' 'extends:'
    printf '%b' "$_extends"
  fi

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
  for stage in commit-msg pre-rebase; do
    has_stage=0
    for name in $ordered; do
      if grep -q "^$stage:" "$FRAGMENTS_DIR/$name.yml"; then
        if [ "$has_stage" -eq 0 ]; then
          printf '\n%s\n' "$stage:"
          printf '%s\n' '  commands:'
          has_stage=1
        fi
        awk -v stage="$stage" '$0 == stage ":" {s=1;next} s&&/^  commands:/{c=1;next} s&&/^[a-z]/{s=0;c=0} c&&NF{print}' "$FRAGMENTS_DIR/$name.yml"
      fi
    done
  done
} >"$out/lefthook.yml"

# A repo-local fragment is appended after the standard fragments. A carried-
# through check can therefore collide with a standard command name. Keep the
# first command for each hook: duplicate YAML mapping keys make lefthook reject
# the whole config.
awk '
  /^(pre-commit|pre-push|commit-msg|pre-rebase):$/ {
    hook = $1
    sub(/:$/, "", hook)
    in_commands = 0
    print
    next
  }
  /^  commands:$/ {
    in_commands = 1
    print
    next
  }
  /^[A-Za-z][A-Za-z0-9_-]*:/ {
    in_commands = 0
    print
    next
  }
  in_commands && /^    [A-Za-z][A-Za-z0-9_-]*:/ {
    key = $0
    sub(/^    /, "", key)
    sub(/:.*/, "", key)
    keep = !(hook SUBSEP key in emitted)
    if (keep) emitted[hook SUBSEP key] = 1
    if (keep) print
    next
  }
  in_commands && keep { print }
  !in_commands { print }
' "$out/lefthook.yml" >"$out/lefthook.yml.dedup"
mv "$out/lefthook.yml.dedup" "$out/lefthook.yml"

# Inject skip:true for migrating commands (parallel-change expand phase).
# Each command name in MIGRATION_SKIPS gets a skip:true line inserted after
# its YAML key line, disabling it in the main config while the migration
# overlay runs the replacement in advisory mode.
if [ -n "${MIGRATION_SKIPS:-}" ]; then
  skip_pattern=""
  for cmd in ${MIGRATION_SKIPS}; do
    if [ -n "$skip_pattern" ]; then
      skip_pattern="${skip_pattern}|"
    fi
    skip_pattern="${skip_pattern}^    ${cmd}:\$"
  done
  awk "/${skip_pattern}/{print; print \"      skip: true\"; next} {print}" \
    "$out/lefthook.yml" >"$out/lefthook.yml.tmp"
  mv "$out/lefthook.yml.tmp" "$out/lefthook.yml"
fi
