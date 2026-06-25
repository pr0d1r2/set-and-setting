#!/usr/bin/env bash
# Emit one category's path-scoped rule files (V17/V18/V19/V25).
# Mirrors each source file verbatim with the category's conditional-load
# field prepended as frontmatter. No SKILL.md, no name/description, no
# concatenation -- each source becomes one rule file. Extracted per
# nix/modularity + sh/modularity: no embedded shell, no functions.
# Env in:
#   CAT        category name
#   DEST_DIR   output base directory (e.g. $out/.claude/rules/set)
#   GLOBS      space-separated conditional-load globs
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

read -ra globs <<<"${GLOBS:-}"

frontmatter="---"$'\n'"$COND_FIELD:"$'\n'
for g in "${globs[@]}"; do
    frontmatter+="  - \"$g\""$'\n'
done
frontmatter+="---"$'\n'$'\n'

mkdir -p "$DEST_DIR"

if [ -n "$core" ] && [ -f "$core" ]; then
    dest="$DEST_DIR/$CAT.md"
    printf '%s' "$frontmatter" >"$dest"
    cat "$core" >>"$dest"
fi

if [ -d "$catdir" ]; then
    find "$catdir" -name '*.md' ${findargs[@]+"${findargs[@]}"} | sort | while read -r f; do
        rel="${f#"$catdir"/}"
        dest="$DEST_DIR/$CAT/$rel"
        mkdir -p "$(dirname "$dest")"
        printf '%s' "$frontmatter" >"$dest"
        cat "$f" >>"$dest"
    done
fi
