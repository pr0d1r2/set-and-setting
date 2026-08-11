#!/usr/bin/env bash
set -euo pipefail
set -f
while IFS= read -r line || [ -n "$line" ]; do
  refs="$(printf '%s\n' "$line" | INPUT=/dev/stdin bash "$REF_MATCH")"
  drop=0
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    case "$ref" in
      @set/*) source="$SET_ROOT/set/${ref#@set/}" ;;
      @*) source="$SET_ROOT/set/skills/${ref#@}" ;;
    esac
    target=""
    while IFS='|' read -r map_source map_dest; do
      if [ "$map_source" = "$source" ]; then target="$map_dest"; break; fi
    done <"$REF_MAP"
    if [ -z "$target" ]; then drop=1; break; fi
    relative="$(realpath -m --relative-to="$(dirname "$DEST")" "$target")"
    line="${line//$ref/@$relative}"
  done <<<"$refs"
  [ "$drop" -eq 0 ] && printf '%s\n' "$line"
done <"$SRC"
