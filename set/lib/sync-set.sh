#!/usr/bin/env bash
# Sync the emitted set into a target dir (default: cwd). Clean-replaces
# the set namespace (V26) then copies the agent artifact tree the package
# carries. Discovers the agent dir (.claude/ or .opencode/) from the
# build output (V21/V23 agent-agnostic).
set -euo pipefail

target="${1:-.}"
src="$(dirname "$(dirname "$(readlink -f "$0")")")"
mkdir -p "$target"

skill_parent=""
for d in "$src"/.*; do
    base="${d##*/}"
    [ "$base" = "." ] || [ "$base" = ".." ] && continue
    [ -d "$d/skills/set" ] || continue
    skill_parent="$base"
    break
done

if [ -n "$skill_parent" ]; then
    rm -rf "$target/$skill_parent/skills/set"
    cp -r "$src/$skill_parent" "$target/"
fi
echo "synced set -> $target"
