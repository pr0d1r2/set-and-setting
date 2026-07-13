#!/usr/bin/env bash
# ref-resolve-check.sh -- resolve every real @-reference in the set/ tree to
# an existing source path (T64). Consumes the T63 matcher (lib/ref-match.sh)
# so only genuine refs are checked -- non-ref @ tokens (emails, git SHAs,
# prose @main/@include) and code-span/comment refs are already filtered out,
# which is exactly what let T58 finally go green (B: a naive grep never did).
#
# Resolution rules (V12/V29), lenient by design -- exit 1 ONLY on a
# truly-missing target, so a ref that resolves under any reasonable base is
# accepted:
#   - @set/...            resolved from the repo root ($ROOT/set/...)
#   - relative @<cat>/<file>.md  resolved against the referencing file's own
#     dir and its parent (sibling category), plus the set/ root and the
#     skills/ and drafts/ subtrees (drafts vs skills).
# Env in:
#   SET_ROOT   the set/ source tree to scan
#   REF_MATCH  path to lib/ref-match.sh (the T63 matcher)
# Stdout: PASS on success, or one FAIL line per unresolved ref.
# Exit: 0 if every ref resolves, 1 if any target is truly missing.
set -euo pipefail

set_root="${SET_ROOT:?SET_ROOT must point at the set/ tree}"
ref_match="${REF_MATCH:?REF_MATCH must point at lib/ref-match.sh}"

# Copy the tree into a writable working root so @set/... resolves from a
# stable repo-root analog regardless of where SET_ROOT lives (e.g. a
# read-only /nix/store path).
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -r "$set_root" "$work/set"
chmod -R u+w "$work"
root="$work"

status=0

while IFS= read -r file; do
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    path="${ref#@}"
    dir="$(dirname "$file")"
    parent="$(dirname "$dir")"
    ok=0
    for cand in \
      "$root/$path" \
      "$dir/$path" \
      "$parent/$path" \
      "$root/set/$path" \
      "$root/set/skills/$path" \
      "$root/set/drafts/$path"; do
      if [ -e "$cand" ]; then
        ok=1
        break
      fi
    done
    if [ "$ok" -eq 0 ]; then
      echo "FAIL: unresolved @-reference '$ref' in ${file#"$root"/}"
      status=1
    fi
  done < <(INPUT="$file" bash "$ref_match")
done < <(find "$work/set" -type f -name '*.md' | sort)

if [ "$status" -eq 0 ]; then
  echo "ref-resolution: all @-references resolve"
fi
exit "$status"
