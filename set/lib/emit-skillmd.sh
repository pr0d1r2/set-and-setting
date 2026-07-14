#!/usr/bin/env bash
# Emit one category's portable SKILL.md (channel c, V20). An
# agentskills.io skill folder set-<cat>/SKILL.md with frontmatter
# (name + description from meta keywords + the agent's conditional-load
# field/globs) and a body that inlines the category's source files
# verbatim, each under a heading. Inlining (rather than separate
# supporting files) keeps the content self-contained for agents without a
# rules channel AND avoids a case-insensitive-filesystem collision
# between a supporting "skill.md" and the entry "SKILL.md" (macOS APFS).
# No disable-model-invocation here -- Claude load dedup is T49. No
# functions (sh/modularity).
# Env in:
#   CAT         category name
#   SKILLS_DIR  root of the agnostic set/skills tree
#   SKILL_DEST  base skills dir (e.g. $out/.claude/skills)
#   KEYWORDS    comma-separated keywords for the description
#   GLOBS       space-separated conditional-load globs
#   COND_FIELD  frontmatter field name (e.g. paths)
#   EXCLUDE     space-separated filenames to omit
#   DISABLE_INVOCATION  "1" to add disable-model-invocation: true (Claude
#                       dedup, V20); "0"/unset to leave it model-invocable
#   KEEP        optional newline-separated relpaths to include (smart
#               materialization, V34); unset/empty = include all
set -euo pipefail

keep_active=0
if [ -n "${KEEP:-}" ]; then
    keep_active=1
fi

dir="$SKILL_DEST/set-$CAT"

catdir="$SKILLS_DIR/$CAT"
core="$SKILLS_DIR/$CAT.md"

read -ra excludes <<<"${EXCLUDE:-}"
findargs=()
for e in "${excludes[@]:-}"; do
    [ -n "$e" ] || continue
    findargs+=(! -name "$e")
    [ "$e" = "$CAT.md" ] && core=""
done

desc="${KEYWORDS//,/, }"
[ -n "$desc" ] || desc="$CAT"

read -ra garr <<<"${GLOBS:-}"

# Collect the kept source files (KEEP filter, V34); skip the whole skill
# folder when nothing is kept.
keep_core=0
if [ -n "$core" ] && [ -f "$core" ]; then
    if [ "$keep_active" -eq 0 ] || printf '%s\n' "$KEEP" | grep -qxF "$CAT.md"; then
        keep_core=1
    fi
fi
tree_files=()
if [ -d "$catdir" ]; then
    while read -r f; do
        sub="${f#"$catdir"/}"
        if [ "$keep_active" -eq 1 ] && ! printf '%s\n' "$KEEP" | grep -qxF "$CAT/$sub"; then
            continue
        fi
        tree_files+=("$f")
    done < <(find "$catdir" -name '*.md' ${findargs[@]+"${findargs[@]}"} | sort)
fi

if [ "$keep_core" -eq 0 ] && [ "${#tree_files[@]}" -eq 0 ]; then
    exit 0
fi

mkdir -p "$dir"
dest="$dir/SKILL.md"
{
    printf '%s\n' "---"
    printf 'name: set-%s\n' "$CAT"
    printf 'description: "%s: %s"\n' "$CAT" "$desc"
    [ "${DISABLE_INVOCATION:-0}" = "1" ] && printf 'disable-model-invocation: true\n'
    printf '%s:\n' "$COND_FIELD"
    for g in "${garr[@]}"; do printf '  - "%s"\n' "$g"; done
    printf '%s\n\n' "---"
    printf '# %s\n' "$CAT"
} >"$dest"

if [ "$keep_core" -eq 1 ]; then
    {
        printf '\n## %s.md\n\n' "$CAT"
        cat "$core"
    } >>"$dest"
fi

for f in "${tree_files[@]}"; do
    sub="${f#"$catdir"/}"
    {
        printf '\n## %s\n\n' "$sub"
        cat "$f"
    } >>"$dest"
done
