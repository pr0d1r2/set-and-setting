#!/usr/bin/env bash
# Orchestrate the multi-channel set emitter (V17, extracted from
# mk-set.nix). Loops the selected categories, invokes emit-skill.sh per
# category to emit always-on (core) + conditional (domain) rules from the
# meta map; copies concepts; installs bin/sync-set. No functions
# (sh/modularity).
# Env in: out, SKILLS_DIR, CONCEPTS_DIR, CONCEPTS (0/1), DIR,
#   COND_FIELD, CATEGORIES, GLOBS_MAP (cat=g1,g2;cat2=g3),
#   EXCLUDE, EMIT (emit-skill.sh path), EMIT_RULE (emit-rule.sh path),
#   CORE (core/always-on category names, V18),
#   OVERRIDES (meta per-file channel overrides, V30), SYNC_SRC.
#   Optional portable SKILL.md channel (V20): SKILL_DIR (agent skills
#   dir, e.g. .claude/skills), EMIT_SKILLMD (emit-skillmd.sh path),
#   KEYWORDS_MAP (cat=kw1,kw2;cat2=kw3). Skipped when SKILL_DIR unset.
# shellcheck disable=SC2154  # $out is provided by the nix runCommand env
# shellcheck disable=SC2153  # SKILLS_DIR and SKILL_DIR are distinct env vars
set -euo pipefail

mkdir -p "$out"

read -ra cats <<<"${CATEGORIES:-}"
IFS=';' read -ra mapentries <<<"${GLOBS_MAP:-}"

for cat in "${cats[@]:-}"; do
    [ -n "$cat" ] || continue

    globs=""
    for entry in "${mapentries[@]:-}"; do
        if [ "${entry%%=*}" = "$cat" ]; then
            val="${entry#*=}"
            globs="${val//,/ }"
            break
        fi
    done

    CAT="$cat" DEST_DIR="$out/$DIR" GLOBS="$globs" COND_FIELD="$COND_FIELD" \
        SKILLS_DIR="$SKILLS_DIR" EXCLUDE="$EXCLUDE" CORE="${CORE:-}" \
        OVERRIDES="${OVERRIDES:-}" EMIT_RULE="$EMIT_RULE" bash "$EMIT"

    # portable SKILL.md channel (V20), if enabled
    if [ -n "${SKILL_DIR:-}" ]; then
        keywords=""
        IFS=';' read -ra kwentries <<<"${KEYWORDS_MAP:-}"
        for entry in "${kwentries[@]:-}"; do
            if [ "${entry%%=*}" = "$cat" ]; then
                keywords="${entry#*=}"
                break
            fi
        done
        CAT="$cat" SKILLS_DIR="$SKILLS_DIR" SKILL_DEST="$out/$SKILL_DIR" \
            KEYWORDS="$keywords" GLOBS="$globs" COND_FIELD="$COND_FIELD" \
            EXCLUDE="$EXCLUDE" DISABLE_INVOCATION="${SKILL_DISABLE_INVOCATION:-0}" \
            bash "$EMIT_SKILLMD"
    fi
done

if [ "$CONCEPTS" = "1" ]; then
    mkdir -p "$out/$DIR"
    find "$CONCEPTS_DIR" -name '*.md' | sort | while read -r f; do
        rel="${f#"$CONCEPTS_DIR"/}"
        cp "$f" "$out/$DIR/concepts-${rel//\//-}"
    done
fi

# Always-on @-manifest (channel a authoring surface, V18; input to the
# @->AGENTS.md compiler, V29). Lists @-refs to every always-on (path-less)
# file under the set dir: concepts first (V2), then core rule files.
# Domain rules (with frontmatter) are conditional, not always-on, so they
# are omitted. Written as a sibling of the set dir so "@<base>/<rel>"
# resolves into it.
setroot="$out/$DIR"
setbase="${DIR##*/}"
manifest="$out/${DIR%/*}/$setbase.md"
mkdir -p "$setroot" "$(dirname "$manifest")"
{
    printf '# Set (always-on)\n\n'
    find "$setroot" -maxdepth 1 -name 'concepts-*.md' | sort | while read -r f; do
        printf '@%s/%s\n' "$setbase" "${f#"$setroot"/}"
    done
    find "$setroot" -name '*.md' ! -name 'concepts-*.md' | sort | while read -r f; do
        head -1 "$f" | grep -q '^---$' && continue
        printf '@%s/%s\n' "$setbase" "${f#"$setroot"/}"
    done
} >"$manifest"

mkdir -p "$out/bin"
cp "$SYNC_SRC" "$out/bin/sync-set"
chmod +x "$out/bin/sync-set"
