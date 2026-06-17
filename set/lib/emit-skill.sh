#!/usr/bin/env bash
# Emit one category's Agent-Skills file (extracted from mk-set.nix per
# nix/modularity + sh/modularity: no embedded shell, no functions).
# Env in:
#   CAT        category name
#   DEST       full output path (caller picks skill-dir vs rules-dir)
#   GLOBS      space-separated conditional-load globs ("" => always-on)
#   COND_FIELD frontmatter field name for the globs (e.g. "paths")
#   SKILLS_DIR root of the agnostic set/skills tree
#   EXCLUDE    space-separated filenames to omit (e.g. "rtk.md")
set -euo pipefail

catdir="$SKILLS_DIR/$CAT"
core="$SKILLS_DIR/$CAT.md"

read -ra excludes <<<"${EXCLUDE:-}"
findargs=()
for e in "${excludes[@]:-}"; do
    [ -n "$e" ] || continue
    findargs+=(! -name "$e")
    [ "$e" = "$CAT.md" ] && core=""
done

descsrc="$core"
if [ -z "$descsrc" ] || [ ! -f "$descsrc" ]; then
    descsrc="$(find "$catdir" -name '*.md' ${findargs[@]+"${findargs[@]}"} | sort | head -1)"
fi

title="$(grep -m1 '^# ' "$descsrc" 2>/dev/null | sed 's/^# *//' || true)"
[ -n "$title" ] || title="$CAT"
purpose="$(grep -m1 -E '^[^#[:space:]]' "$descsrc" 2>/dev/null | tr -d '"' || true)"
desc="$title"
[ -n "$purpose" ] && desc="$title -- $purpose"

read -ra globs <<<"${GLOBS:-}"

mkdir -p "$(dirname "$DEST")"
{
    echo "---"
    echo "name: $CAT"
    echo "description: \"$desc\""
    if [ "${#globs[@]}" -gt 0 ]; then
        echo "$COND_FIELD:"
        for g in "${globs[@]}"; do
            echo "  - \"$g\""
        done
    fi
    echo "---"
    echo
    [ -n "$core" ] && [ -f "$core" ] && {
        cat "$core"
        echo
    }
    find "$catdir" -name '*.md' ${findargs[@]+"${findargs[@]}"} | sort | while read -r f; do
        cat "$f"
        echo
    done
} >"$DEST"
