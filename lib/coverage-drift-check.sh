#!/usr/bin/env bash
# Coverage-drift comparator, extracted from mk-coverage-drift-check.nix
# (nix/modularity: no embedded shell in nix files). Compares the checks a
# consumer's fragments claim (EXPECTED_PINNED plus the commands in the
# standard's own emitted hook) against what the consumer actually emits
# (its hook commands plus CONSUMER_CHECKS). Missing entries exit 1; extra
# entries are reported as allowed repo-local checks.
#
# The command extractor is inlined at both sites rather than shared: this
# repository forbids shell functions, and the awk program is the whole of it.
set -euo pipefail

expected=$(mktemp)
actual=$(mktemp)
trap 'rm -f "$expected" "$actual"' EXIT

{
  printf '%s\n' "$EXPECTED_PINNED"
  awk '
    /^    [A-Za-z0-9][A-Za-z0-9_.-]*:$/ {
      name=$0; sub(/^    /, "", name); sub(/:$/, "", name); print name
    }
  ' "$EXPECTED_HOOK" | sort -u
} | sed '/^$/d' | sort -u >"$expected"

{
  printf '%s\n' "$EXPECTED_PINNED"
  awk '
    /^    [A-Za-z0-9][A-Za-z0-9_.-]*:$/ {
      name=$0; sub(/^    /, "", name); sub(/:$/, "", name); print name
    }
  ' "$ACTUAL_HOOK" | sort -u
  printf '%s\n' "$CONSUMER_CHECKS"
} | sed '/^$/d' | sort -u >"$actual"

missing=$(comm -23 "$expected" "$actual" || true)
if [ -n "$missing" ]; then
  echo "coverage-drift: missing emitted checks for fragments [$FRAGMENTS]:" >&2
  printf '  %s\n' "$missing" >&2
  exit 1
fi

extra=$(comm -13 "$expected" "$actual" || true)
if [ -n "$extra" ]; then
  echo "coverage-drift: repo-local checks (allowed):" >&2
  printf '  %s\n' "$extra" >&2
fi
echo "coverage-drift: PASS"
