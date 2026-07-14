#!/usr/bin/env bash
# skill-extension-check.sh -- enforce V6/V13: only *.md files in set/skills/
# and set/drafts/ (T56). Pure find + exit-on-non-md. No content parsing.
# Env in:
#   SET_ROOT  the set/ source tree to scan
# Stdout: PASS on success, or one FAIL line per non-md file.
# Exit: 0 if all files are *.md, 1 if any non-md file found.
set -euo pipefail

set_root="${SET_ROOT:?SET_ROOT must point at the set/ tree}"

status=0

for subdir in skills drafts; do
    dir="$set_root/$subdir"
    [ -d "$dir" ] || continue
    while IFS= read -r file; do
        [ -n "$file" ] || continue
        echo "FAIL: non-md file '${file#"$set_root"/}' in $subdir/"
        status=1
    done < <(find "$dir" -type f ! -name '*.md' | sort)
done

if [ "$status" -eq 0 ]; then
    echo "skill-extension: all files in skills/ and drafts/ are *.md"
fi
exit "$status"
