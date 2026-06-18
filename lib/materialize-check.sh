#!/usr/bin/env bash
# Verify that mkSet materialization produces the expected layout for the
# requested categories. Assertions are self-derived from categories.nix
# (via GLOBS_MAP + CORE_CATEGORIES env), so the consumer never restates
# globs. Extracted per nix/modularity + sh/modularity.
# Env in:
#   MATERIALIZED  path to the mkSet output tree
#   SKILL_PATH    agent skill dir (e.g. .claude/skills/set)
#   RULE_PATH     agent rule dir (e.g. .claude/rules)
#   COND_FIELD    frontmatter field name (e.g. paths)
#   CATEGORIES    space-separated categories that were requested
#   GLOBS_MAP     semicolon-separated cat=g1,g2;cat2=g3
#   EXCLUDE       space-separated filenames that were excluded
set -euo pipefail

read -ra cats <<<"${CATEGORIES:-}"
IFS=';' read -ra mapentries <<<"${GLOBS_MAP:-}"
read -ra excludes <<<"${EXCLUDE:-}"

fail=0

for cat in "${cats[@]:-}"; do
    [ -n "$cat" ] || continue

    raw_globs=""
    for entry in "${mapentries[@]:-}"; do
        if [ "${entry%%=*}" = "$cat" ]; then
            raw_globs="${entry#*=}"
            break
        fi
    done

    if [ -n "$raw_globs" ]; then
        skill="$MATERIALIZED/$SKILL_PATH/$cat/SKILL.md"

        [ -f "$skill" ] || {
            echo "FAIL: $cat: SKILL.md missing at $SKILL_PATH/$cat/SKILL.md"
            fail=1
            continue
        }

        grep -q "^${COND_FIELD}:" "$skill" || {
            echo "FAIL: $cat: SKILL.md missing $COND_FIELD frontmatter"
            fail=1
        }

        IFS=',' read -ra expected_globs <<<"$raw_globs"
        for g in "${expected_globs[@]}"; do
            grep -qF "\"$g\"" "$skill" || {
                echo "FAIL: $cat: SKILL.md missing glob \"$g\""
                fail=1
            }
        done

        destdir="$(dirname "$skill")"
        while IFS= read -r facet; do
            [ -n "$facet" ] || continue
            if head -1 "$facet" | grep -q '^---'; then
                echo "FAIL: $cat: facet $(basename "$facet") has frontmatter (V25 violation)"
                fail=1
            fi
        done < <(find "$destdir" -name '*.md' ! -name 'SKILL.md' 2>/dev/null)
    else
        rule="$MATERIALIZED/$RULE_PATH/$cat.md"

        [ -f "$rule" ] || {
            echo "FAIL: $cat: rule file missing at $RULE_PATH/$cat.md"
            fail=1
            continue
        }

        if grep -q "^${COND_FIELD}:" "$rule"; then
            echo "FAIL: $cat: always-on rule has $COND_FIELD field (should not)"
            fail=1
        fi
    fi
done

for ex in "${excludes[@]:-}"; do
    [ -n "$ex" ] || continue
    if find "$MATERIALIZED" -name "$ex" 2>/dev/null | grep -q .; then
        echo "FAIL: excluded file $ex found in output"
        fail=1
    fi
done

manifest="$MATERIALIZED/$SKILL_PATH/.mkset.json"
if [ -f "$manifest" ]; then
    for cat in "${cats[@]:-}"; do
        [ -n "$cat" ] || continue
        grep -qF "\"$cat\"" "$manifest" || {
            echo "FAIL: manifest missing category $cat"
            fail=1
        }
    done
fi

if [ "$fail" -ne 0 ]; then
    echo "MATERIALIZATION CHECK FAILED"
    exit 1
fi

echo "PASS"
