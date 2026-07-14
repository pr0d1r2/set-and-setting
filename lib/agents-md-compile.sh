#!/usr/bin/env bash
# Resolve a Claude @-manifest into inline content (V29/I.compiler). Mirrors
# Claude's @-parse rules so the compiled AGENTS.md == what Claude loads:
#   - inline a standalone @<path> ref line (leading whitespace allowed)
#   - recurse into referenced files, up to MAXDEPTH hops
#   - skip @ inside fenced code blocks (``` / ~~~) and code spans (backtick)
#   - strip block-level HTML comments (<!-- ... -->), even multi-line
#   - leave an unresolvable or over-depth @ ref as a literal line
# Recurses by invoking itself per referenced file (sh/modularity: no
# functions). Prints the resolved content to stdout.
# Env in:
#   INPUT     file to process
#   BASE      dir to resolve @<path> against (the file's own dir)
#   SELF      path to this script (for recursion)
#   DEPTH     current hop (default 0)
#   MAXDEPTH  max hops (default 4)
set -euo pipefail

depth="${DEPTH:-0}"
maxdepth="${MAXDEPTH:-4}"

in_fence=0
in_comment=0

while IFS= read -r line || [ -n "$line" ]; do
  # Continue stripping an open block-level HTML comment.
  if [ "$in_comment" -eq 1 ]; then
    case "$line" in
      *'-->'*)
        line="${line#*-->}"
        in_comment=0
        ;;
      *) continue ;;
    esac
  fi

  # Strip any complete <!-- ... --> comments on this line.
  while
    case "$line" in
      *'<!--'*'-->'*) true ;;
      *) false ;;
    esac
  do
    line="${line%%'<!--'*}${line#*-->}"
  done

  # An opening <!-- with no close: drop the rest and enter comment state.
  case "$line" in
    *'<!--'*)
      line="${line%%'<!--'*}"
      in_comment=1
      ;;
  esac

  # Fenced code block toggle: emit the fence and flip state.
  case "$line" in
    '```'* | '~~~'*)
      in_fence=$((1 - in_fence))
      printf '%s\n' "$line"
      continue
      ;;
  esac

  if [ "$in_fence" -eq 1 ]; then
    printf '%s\n' "$line"
    continue
  fi

  # Standalone @<path> reference line (leading whitespace allowed).
  trimmed="${line#"${line%%[![:space:]]*}"}"
  case "$trimmed" in
    '@'*)
      # A backtick means it is a code span -> leave literal.
      case "$trimmed" in
        *'`'*)
          printf '%s\n' "$line"
          continue
          ;;
      esac
      ref="${trimmed#@}"
      ref="${ref%%[[:space:]]*}"
      target="$BASE/$ref"
      if [ "$depth" -ge "$maxdepth" ] || [ ! -f "$target" ]; then
        printf '%s\n' "$line"
        continue
      fi
      env INPUT="$target" BASE="$(dirname "$target")" SELF="$SELF" \
        DEPTH="$((depth + 1))" MAXDEPTH="$maxdepth" bash "$SELF"
      continue
      ;;
  esac

  printf '%s\n' "$line"
done <"$INPUT"
