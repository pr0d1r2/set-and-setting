#!/usr/bin/env bash
set -euo pipefail

status=0
for path in "$@"; do
  case "$path" in
    .github/workflows/*.yml | .github/workflows/*.yaml | */.github/workflows/*.yml | */.github/workflows/*.yaml)
      awk -v path="$path" '
        function report(action, ref) {
          printf "%s:%d: pin %s to a full 40-character commit SHA; resolve with: git ls-remote https://github.com/%s refs/heads/%s (or refs/tags/%s)\n", path, FNR, action "@" ref, repo, ref, ref
          found = 1
        }
        {
          line = $0
          if (line !~ /^[[:space:]]*(-[[:space:]]*)?[\047\042]?uses[\047\042]?[[:space:]]*:[[:space:]]*/) next
          sub(/^[[:space:]]*(-[[:space:]]*)?[\047\042]?uses[\047\042]?[[:space:]]*:[[:space:]]*/, "", line)
          sub(/[[:space:]]+#.*$/, "", line)
          split(line, fields, /[[:space:]]+/)
          action_ref = fields[1]
          gsub(/^[\047\042]|[\047\042]$/, "", action_ref)
          if (action_ref ~ /^\.\//) next
          split(action_ref, parts, "@")
          action = parts[1]
          ref = parts[2]
          if (action == "" || ref !~ /^[0-9A-Fa-f]{40}$/) {
            split(action, owner_repo, "/")
            repo = owner_repo[1] "/" owner_repo[2]
            report(action, ref)
          }
        }
        END { if (found) exit 1 }
      ' "$path" || status=1
      ;;
  esac
done
exit "$status"
