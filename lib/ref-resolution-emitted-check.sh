#!/usr/bin/env bash
# Resolve real @-references in an emitted mkSet tree. Unlike the source-side
# check, this intentionally has no source-tree fallback: emitted refs are
# paths relative to the file that contains them.
set -euo pipefail

artifact_root="${ARTIFACT_ROOT:?ARTIFACT_ROOT must point at an emitted tree}"
ref_match="${REF_MATCH:?REF_MATCH must point at lib/ref-match.sh}"
status=0

while IFS= read -r file; do
  dir="$(dirname "$file")"
  line_no=0
  while IFS= read -r line || [ -n "$line" ]; do
    line_no=$((line_no + 1))
    while IFS= read -r ref; do
      [ -n "$ref" ] || continue
      target="${ref#@}"
      if [ ! -e "$dir/$target" ]; then
        echo "FAIL: unresolved @-reference '$ref' in ${file#"$artifact_root"/}:$line_no (target ${target})"
        status=1
      fi
    done < <(printf '%s\n' "$line" | INPUT=/dev/stdin bash "$ref_match")
  done <"$file"
done < <(find "$artifact_root" -type f -name '*.md' | sort)

if [ "$status" -eq 0 ]; then
  echo "emitted-ref-resolution: all @-references resolve"
fi
exit "$status"
