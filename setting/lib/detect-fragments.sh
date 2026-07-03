#!/usr/bin/env bash
# detect-fragments.sh -- detect which lefthook fragments apply to a repo.
# Examines tracked files in CWD (via git ls-files) to determine which
# integration fragments should be included in lefthook.yml.
# Stdout: space-separated ordered fragment names.
# If no tracked files found (bare repo), defaults to all fragments.
# shellcheck disable=SC2154
set -euo pipefail

if git rev-parse --git-dir >/dev/null 2>&1; then
    tracked="$(git ls-files 2>/dev/null || true)"
else
    tracked=""
fi

if [ -z "$tracked" ]; then
    echo "base nix shell ascii markdown yaml"
    exit 0
fi

result="base"

if printf '%s\n' "$tracked" | grep -qE '\.nix$'; then
    result="$result nix"
fi

if printf '%s\n' "$tracked" | grep -qE '\.(sh|bash)$'; then
    result="$result shell"
fi

result="$result ascii"

if printf '%s\n' "$tracked" | grep -qE '\.md$'; then
    result="$result markdown"
fi

if printf '%s\n' "$tracked" | grep -qE '\.(yml|yaml)$'; then
    result="$result yaml"
fi

echo "$result"
