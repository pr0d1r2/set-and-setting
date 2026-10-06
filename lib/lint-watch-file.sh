#!/usr/bin/env bash
# Require .envrc watch_file entries for shell scripts read by Nix files.
set -euo pipefail

status=0
root=$(pwd -P)

for path in "$@"; do
  case "$path" in
    *.nix) ;;
    *) continue ;;
  esac

  while IFS=$'\t' read -r line ref; do
    [ -n "$ref" ] || continue
    resolved=$(readlink -f "$(dirname "$path")/$ref") || continue
    case "$resolved" in
      "$root"/*) relative=${resolved#"$root"/} ;;
      *) continue ;;
    esac
    if ! grep -Eq "^[[:space:]]*watch_file[[:space:]]+$relative([[:space:]]*)$" .envrc 2>/dev/null; then
      printf "%s:%s: add \`watch_file %s\` to .envrc\\n" "$path" "$line" "$relative"
      status=1
    fi
  done < <(awk '
    /^[[:space:]]*#/ { next }
    {
      line = $0
      while (match(line, /readFile[[:space:]]+\.\.?\/[A-Za-z0-9_./+@%=-]+\.sh/)) {
        ref = substr(line, RSTART, RLENGTH)
        sub(/^readFile[[:space:]]+/, "", ref)
        print NR "\t" ref
        line = substr(line, RSTART + RLENGTH)
      }
    }
  ' "$path")
done

exit "$status"
