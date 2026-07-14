#!/usr/bin/env bash
# skill-size-check.sh -- enforce per-file size limit on individual skill/draft
# markdown (T57). Single wc -c check. Independent of format or structure checks.
# Env in:
#   SET_ROOT         the set/ source tree to scan
#   SKILL_SIZE_LIMIT max bytes per file (default: 4096)
# Stdout: PASS on success, or one FAIL line per oversized file.
# Exit: 0 if all files within budget, 1 if any file exceeds limit.
set -euo pipefail

set_root="${SET_ROOT:?SET_ROOT must point at the set/ tree}"
limit="${SKILL_SIZE_LIMIT:-4096}"

status=0

for subdir in skills drafts; do
  dir="$set_root/$subdir"
  [ -d "$dir" ] || continue
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    size="$(wc -c <"$file")"
    if [ "$size" -gt "$limit" ]; then
      echo "FAIL: '${file#"$set_root"/}' is ${size} bytes (limit: ${limit})"
      status=1
    fi
  done < <(find "$dir" -type f -name '*.md' | sort)
done

if [ "$status" -eq 0 ]; then
  echo "skill-size: all files in skills/ and drafts/ within ${limit}-byte limit"
fi
exit "$status"
