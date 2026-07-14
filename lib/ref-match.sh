#!/usr/bin/env bash
# ref-match.sh -- emit ONLY real @-references from a markdown file (T63).
# The false-positive filter that unblocked T58: a plain grep for '@' also
# flags non-ref tokens (emails, git SHAs, prose @main/@include), so a naive
# resolution lint never goes green. This scanner emits just the genuine refs.
#
# A real @-reference is a LEADING @-token (the @ starts the whitespace-split
# word, so `action@main` is not one) whose path is one of the V12/V29 forms:
#   - @set/...            (leading-token, path under the set/ tree)
#   - @concepts/...       (leading-token, relative concepts ref)
#   - @<category>/<file>.md (relative bundle ref -- has a / and ends .md)
# SKIPPED (V29 parse rules + false-positive filter):
#   - code spans (`...`) and fenced blocks (``` / ~~~)
#   - block-level HTML comments (<!-- ... -->), even multi-line
#   - non-ref @ tokens: email @example.com, git SHAs @fbeb9d9, prose
#     @include / @main / @v4 / @privileged / @system-service (no /, or the
#     @ is not word-initial)
# Consumed by the T64 ref-resolution check; ships standalone (no repo gate).
# Env in:
#   INPUT   markdown file to scan
# Stdout: one real @-reference per line, including the leading @.
# shellcheck disable=SC2154
set -euo pipefail
# Disable globbing: word-splitting the line must not expand `*` in glob-like
# tokens (e.g. a literal `**/*.md`) against the working directory.
set -f

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

    # Fenced code block toggle: the fence line itself carries no ref.
    case "$line" in
        '```'* | '~~~'*)
            in_fence=$((1 - in_fence))
            continue
            ;;
    esac
    if [ "$in_fence" -eq 1 ]; then
        continue
    fi

    # Strip paired inline code spans so a @ref inside backticks is ignored,
    # while a real ref elsewhere on the same line still counts.
    while
        case "$line" in
            *'`'*'`'*) true ;;
            *) false ;;
        esac
    do
        before="${line%%'`'*}"
        after="${line#*'`'}"
        after="${after#*'`'}"
        line="$before $after"
    done

    # A leading @-token = a whitespace-split word starting with @. This is the
    # "leading-token" rule: `action@main` (word does not start with @) is out.
    for word in $line; do
        case "$word" in
            '@'*) ;;
            *) continue ;;
        esac
        # Trim trailing prose punctuation that is never part of a ref path.
        tok="${word#@}"
        tok="${tok%%[)\],;:]}"
        # Keep only the three real forms; everything else is a false positive.
        case "$tok" in
            set/?* | concepts/?*) printf '@%s\n' "$tok" ;;
            */*.md) printf '@%s\n' "$tok" ;;
            *) : ;;
        esac
    done
done <"$INPUT"
