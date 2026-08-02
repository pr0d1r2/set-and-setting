#!/usr/bin/env bash
# detect-fragments.sh -- detect which lefthook fragments apply to a repo.
# Examines tracked files in CWD (via git ls-files), or a source tree supplied
# through DETECT_ROOT, to determine which fragments apply.
# Stdout: space-separated ordered fragment names.
# If no tracked files found (bare repo), defaults to all fragments.
# shellcheck disable=SC2154
set -euo pipefail

if [ -n "${DETECT_ROOT:-}" ]; then
  tracked="$(find -L "$DETECT_ROOT" -type f -printf '%P\n' | sort)"
elif git rev-parse --git-dir >/dev/null 2>&1; then
  tracked="$(git ls-files 2>/dev/null || true)"
else
  tracked=""
fi

if [ -z "$tracked" ] && [ -n "${DETECT_ROOT:-}" ]; then
  echo "base ascii"
  exit 0
fi

if [ -z "$tracked" ]; then
  echo "base nix shell rubocop ascii markdown yaml set"
  exit 0
fi

result="base"

if grep -qE '\.nix$' <<<"$tracked"; then
  result="$result nix"
fi

if grep -qE '\.(sh|bash)$' <<<"$tracked"; then
  result="$result shell"
fi

if grep -qE '(^|/)\.rubocop\.yml$|\.gemspec$' <<<"$tracked"; then
  result="$result rubocop"
fi

result="$result ascii"

if grep -qE '\.md$' <<<"$tracked"; then
  result="$result markdown"
fi

if grep -qE '\.(yml|yaml)$' <<<"$tracked"; then
  result="$result yaml"
fi

if grep -qE '^set/.*\.md$' <<<"$tracked"; then
  result="$result set"
fi

echo "$result"
