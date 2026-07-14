#!/usr/bin/env bash
# Smart-materialization applicability filter (V34/V35/V36, I.applicability).
# Given the per-file meta signals + the consumer's tracked file list,
# decide which skill files are applicable:
#   - a core-category file is always kept;
#   - a domain file is kept iff some tracked file matches its `paths` AND
#     (its `content` is empty OR a path-matched file contains a content
#     pattern) -- boolean now, scored later;
#   - then facet -> topic-core backfill: a kept facet <topic>/<x>.md
#     force-keeps its <topic>.md core (V36).
# Prints "relpath|reason" per kept file, sorted. No functions
# (sh/modularity).
# Env in:
#   SIGNALS  per-file signal lines "relpath|p1,p2|c1,c2"
#   CORE     space-separated core (always-on) category names
#   TRACKED  newline-separated consumer tracked files (vendored-excluded)
set -uo pipefail
shopt -s globstar extglob

mapfile -t tracked <<<"${TRACKED:-}"

declare -A hassig reason

# pass 1: record every signalled file + decide per-file evidence.
while IFS='|' read -r rel paths content; do
    [ -n "$rel" ] || continue
    hassig["$rel"]=1

    case "$rel" in
        */*) cat="${rel%%/*}" ;;
        *) cat="${rel%.md}" ;;
    esac

    is_core=0
    for c in ${CORE:-}; do
        [ "$c" = "$cat" ] && is_core=1 && break
    done
    if [ "$is_core" -eq 1 ]; then
        reason["$rel"]="core"
        continue
    fi

    # path match: does any tracked file have this shape?
    matched=()
    IFS=',' read -ra globs <<<"$paths"
    for g in "${globs[@]}"; do
        [ -n "$g" ] || continue
        # gitignore/Claude semantics: a leading "**/" matches zero or more
        # dirs, INCLUDING top-level files. bash globstar does not, so also
        # try the pattern with a leading "**/" stripped.
        gtop="${g#'**/'}"
        for f in "${tracked[@]}"; do
            [ -n "$f" ] || continue
            # shellcheck disable=SC2053
            if [[ "$f" == $g ]] || [[ "$f" == $gtop ]]; then
                matched+=("$f")
            fi
        done
    done
    [ "${#matched[@]}" -gt 0 ] || continue

    # content match: paths-only signal -> applicable on path evidence;
    # otherwise a path-matched file must contain a content pattern.
    if [ -z "$content" ]; then
        reason["$rel"]="paths:${globs[0]}"
        continue
    fi
    pat="${content//,/|}"
    if grep -lE "$pat" "${matched[@]}" >/dev/null 2>&1; then
        reason["$rel"]="content:${content}"
    fi
done <<<"${SIGNALS:-}"

# pass 2: facet -> topic core backfill (V36).
for rel in "${!reason[@]}"; do
    case "$rel" in
        */*)
            core="${rel%%/*}.md"
            if [ -n "${hassig[$core]:-}" ] && [ -z "${reason[$core]:-}" ]; then
                reason["$core"]="required-by:${rel%%/*}"
            fi
            ;;
    esac
done

for rel in "${!reason[@]}"; do
    printf '%s|%s\n' "$rel" "${reason[$rel]}"
done | sort
