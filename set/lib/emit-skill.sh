#!/usr/bin/env bash
# Emit one category's Agent-Skills file (extracted from mk-set.nix per
# nix/modularity + sh/modularity: no embedded shell, no functions).
# Domain categories (GLOBS non-empty) emit facets-as-linked-files (V25):
# SKILL.md links raw facet clones via markdown. Always-on categories
# (GLOBS empty) concatenate all files into a single rule (no facets).
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

if [ "${#globs[@]}" -eq 0 ]; then
    # Always-on rule: concatenate all files into one (no facets)
    {
        echo "---"
        echo "name: $CAT"
        echo "description: \"$desc\""
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
else
    # Domain skill: facets-as-linked-files (V25, V26)
    destdir="$(dirname "$DEST")"
    {
        echo "---"
        echo "name: $CAT"
        echo "description: \"$desc\""
        echo "$COND_FIELD:"
        for g in "${globs[@]}"; do
            echo "  - \"$g\""
        done
        echo "---"
        echo
        [ -n "$core" ] && [ -f "$core" ] && {
            cat "$core"
            echo
        }
        find "$catdir" -name '*.md' ${findargs[@]+"${findargs[@]}"} | sort | while read -r f; do
            rel="${f#"$catdir"/}"
            ftitle="$(grep -m1 '^# ' "$f" 2>/dev/null | sed 's/^# *//' || true)"
            [ -n "$ftitle" ] || ftitle="$rel"
            fnote="$(grep -m1 -E '^[^#[:space:]]' "$f" 2>/dev/null || true)"
            if [ -n "$fnote" ]; then
                echo "- [$ftitle]($rel) -- $fnote"
            else
                echo "- [$ftitle]($rel)"
            fi
        done
    } >"$DEST"
    find "$catdir" -name '*.md' ${findargs[@]+"${findargs[@]}"} | sort | while read -r f; do
        rel="${f#"$catdir"/}"
        mkdir -p "$destdir/$(dirname "$rel")"
        cp "$f" "$destdir/$rel"
    done
fi
