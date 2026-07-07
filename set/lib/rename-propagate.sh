#!/usr/bin/env bash
# rename-propagate.sh -- detect upstream skill renames affecting the
# consumer's install (T24/C7). Compares the rename map against the
# consumer's prior manifest and scans consumer files for stale
# @-references. Advisory (exit 0); reports to stdout. No functions
# (sh/modularity).
#
# Env in:
#   RENAMES_MAP     "old|new" lines (serialized from set/renames.nix)
#   OLD_MANIFEST    path to consumer's .mkset.json saved before sync
#   TARGET_DIR      consumer repo root (for @-ref scanning)
#   AGENT_DIR       agent rules dir relative path (e.g. .claude/rules/set)
set -euo pipefail

[ -z "${RENAMES_MAP:-}" ] && exit 0

found=0
renames_json=""

while IFS='|' read -r old_path new_path; do
    [ -n "$old_path" ] || continue
    [ -n "$new_path" ] || continue

    hit=0

    # Check if the old manifest references the renamed path (applicability
    # keys or any occurrence of the old path string).
    if [ -f "${OLD_MANIFEST:-/dev/null}" ]; then
        if grep -qF "\"$old_path\"" "$OLD_MANIFEST" 2>/dev/null; then
            hit=1
        fi
        # Also check by category: extract the category from the old path
        # and see if the manifest installed that category.
        old_cat="${old_path%%/*}"
        [ "$old_cat" = "$old_path" ] && old_cat="${old_path%.md}"
        if grep -qF "\"$old_cat\"" "$OLD_MANIFEST" 2>/dev/null; then
            hit=1
        fi
    fi

    # Scan consumer files for @-references to the old path.
    if [ -n "${TARGET_DIR:-}" ]; then
        for ref_file in CLAUDE.md CAVE.md AGENTS.md; do
            f="$TARGET_DIR/$ref_file"
            [ -f "$f" ] || continue
            if grep -qF "$old_path" "$f" 2>/dev/null; then
                if [ "$found" -eq 0 ]; then
                    echo "Upstream skill renames detected:"
                fi
                echo "  $ref_file references renamed skill: $old_path -> $new_path"
                found=1
                hit=1
            fi
        done
    fi

    if [ "$hit" -eq 1 ]; then
        if [ "$found" -eq 0 ]; then
            echo "Upstream skill renames detected:"
        fi
        echo "  $old_path -> $new_path"
        found=1
    fi

    # Accumulate for manifest JSON regardless of hit (full rename history).
    [ -n "$renames_json" ] && renames_json="$renames_json,"
    renames_json="$renames_json\"$old_path\":\"$new_path\""
done <<<"$RENAMES_MAP"

if [ "$found" -eq 1 ]; then
    echo ""
    echo "Synced copies updated automatically. Check external references."
fi

# Export the JSON fragment for the caller to include in the manifest.
printf '%s' "$renames_json" >"${RENAMES_OUT:-/dev/null}"
