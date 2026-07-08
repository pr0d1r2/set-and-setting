#!/usr/bin/env bash
# bundle-content-check.sh -- V12 bundle own-content enforcement (T65).
# A *bundle* is a file that composes atomics via `@` references; V12 limits
# its OWN content to a single heading + a purpose statement + the `@` refs.
# This is the standalone grep check that ships separate from ref resolution
# (T64): it never resolves a ref, it only enforces the own-content budget.
#
# Bundle detection consumes the T63 matcher (lib/ref-match.sh): a file is a
# bundle iff the matcher emits at least one real `@`-reference for it. That
# reuses the false-positive filter (emails, git SHAs, prose @main/@include,
# code-span/comment refs never count), so prose files are not mistaken for
# bundles.
#
# For each bundle, every line must be one of: blank, the (single) heading,
# a purpose-statement prose line, or an `@`-ref line. Structural markdown --
# fenced code, list items, table rows, blockquotes -- is atomic content that
# belongs in a composed file, never in the bundle itself, so any of these
# fails the check (exit 1). More than one heading likewise fails (V12:
# "heading" is singular). `@` refs are written as bare leading-token lines
# (the repo convention); a ref dressed as a `- @...` list item is therefore
# flagged as a list item -- intentional.
# Env in:
#   SET_ROOT   the set/ source tree to scan
#   REF_MATCH  path to lib/ref-match.sh (the T63 matcher)
# Stdout: PASS summary on success, or one FAIL line per offending line.
# Exit: 0 if every bundle stays within budget, 1 otherwise.
set -euo pipefail
# Disable globbing so glob-like tokens in a line (e.g. `**/*.md`) are never
# expanded against the working directory during word/pattern operations.
set -f

set_root="${SET_ROOT:?SET_ROOT must point at the set/ tree}"
ref_match="${REF_MATCH:?REF_MATCH must point at lib/ref-match.sh}"

# Work from a writable copy so a read-only /nix/store SET_ROOT is fine.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -r "$set_root" "$work/set"
chmod -R u+w "$work"
root="$work"

status=0

# Scan each bundle inline (no shell functions -- house rule). A bundle is a
# file the matcher finds a real @-ref in; every line must be blank, the one
# heading, a purpose-statement prose line, or a bare @-ref line.
while IFS= read -r file; do
    # Bundle iff the T63 matcher emits at least one real ref.
    [ -n "$(INPUT="$file" bash "$ref_match")" ] || continue

    rel="${file#"$root"/}"
    in_fence=0
    headings=0
    ln=0
    while IFS= read -r line || [ -n "$line" ]; do
        ln=$((ln + 1))
        # Strip leading whitespace for structural classification.
        trimmed="${line#"${line%%[![:space:]]*}"}"

        # Fenced code: report the opening fence once, then skip the body so a
        # single block yields a single violation.
        case "$trimmed" in
            '```'* | '~~~'*)
                if [ "$in_fence" -eq 1 ]; then
                    in_fence=0
                else
                    in_fence=1
                    echo "FAIL: $rel:$ln fenced code block -- bundles compose via @, not inline content (V12)"
                    status=1
                fi
                continue
                ;;
        esac
        if [ "$in_fence" -eq 1 ]; then
            continue
        fi

        # Blank lines are always fine.
        [ -n "$trimmed" ] || continue

        case "$trimmed" in
            '#'*)
                headings=$((headings + 1))
                if [ "$headings" -gt 1 ]; then
                    echo "FAIL: $rel:$ln extra heading -- a bundle carries one heading (V12)"
                    status=1
                fi
                ;;
            '|'*)
                echo "FAIL: $rel:$ln table row -- not heading/purpose/@ref (V12)"
                status=1
                ;;
            '>'*)
                echo "FAIL: $rel:$ln blockquote -- not heading/purpose/@ref (V12)"
                status=1
                ;;
            [-+*]' '* | [-+*]$'\t'*)
                echo "FAIL: $rel:$ln list item -- refs are bare @ lines, not bullets (V12)"
                status=1
                ;;
            [0-9]'. '* | [0-9][0-9]'. '*)
                echo "FAIL: $rel:$ln ordered list item -- not heading/purpose/@ref (V12)"
                status=1
                ;;
            *)
                # Prose purpose statement or a bare @-ref line: allowed.
                :
                ;;
        esac
    done <"$file"
done < <(find "$work/set" -type f -name '*.md' | sort)

if [ "$status" -eq 0 ]; then
    echo "bundle-content: all bundle files limit own content to heading + purpose + refs"
fi
exit "$status"
