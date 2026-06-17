#!/usr/bin/env bash
# Sync the emitted set into a target dir (default: cwd). Clean-replaces
# the set namespace (V26) then copies the agent artifact tree (.claude/)
# the package carries. Gitignored in consumers; refreshed on devShell
# entry.
set -euo pipefail

target="${1:-.}"
src="$(dirname "$(dirname "$(readlink -f "$0")")")"
mkdir -p "$target"
rm -rf "$target/.claude/skills/set"
cp -r "$src/.claude" "$target/" 2>/dev/null || true
echo "synced set -> $target"
