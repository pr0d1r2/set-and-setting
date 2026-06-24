#!/usr/bin/env bash
# Verify that mkSet materialization produces the expected layout for the
# requested categories. Each category's files are path-scoped rules under
# DIR/ (V17/V18/V19/V25): every .md has the conditional-load field.
# Assertions self-derive from categories.nix (via GLOBS_MAP env).
# Extracted per nix/modularity + sh/modularity.
# Env in:
#   MATERIALIZED  path to the mkSet output tree
#   DIR           agent rules dir (e.g. .claude/rules/set)
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

    catdir="$MATERIALIZED/$DIR/$cat"
    corefile="$MATERIALIZED/$DIR/$cat.md"
    has_files=0

    if [ -f "$corefile" ]; then
        has_files=1
        grep -q "^${COND_FIELD}:" "$corefile" || {
            echo "FAIL: $cat.md missing $COND_FIELD frontmatter"
            fail=1
        }
        if [ -n "$raw_globs" ]; then
            IFS=',' read -ra expected_globs <<<"$raw_globs"
            for g in "${expected_globs[@]}"; do
                grep -qF "\"$g\"" "$corefile" || {
                    echo "FAIL: $cat.md missing glob \"$g\""
                    fail=1
                }
            done
        fi
    fi

    if [ -d "$catdir" ]; then
        has_files=1
        while IFS= read -r rule; do
            [ -n "$rule" ] || continue
            relname="${rule#"$catdir"/}"
            grep -q "^${COND_FIELD}:" "$rule" || {
                echo "FAIL: $cat/$relname missing $COND_FIELD frontmatter"
                fail=1
            }
            if [ -n "$raw_globs" ]; then
                IFS=',' read -ra expected_globs <<<"$raw_globs"
                for g in "${expected_globs[@]}"; do
                    grep -qF "\"$g\"" "$rule" || {
                        echo "FAIL: $cat/$relname missing glob \"$g\""
                        fail=1
                    }
                done
            fi
        done < <(find "$catdir" -name '*.md' 2>/dev/null | sort)
    fi

    if [ "$has_files" -eq 0 ]; then
        echo "FAIL: $cat: no rule files found at $DIR/$cat/ or $DIR/$cat.md"
        fail=1
    fi
done

for ex in "${excludes[@]:-}"; do
    [ -n "$ex" ] || continue
    if find "$MATERIALIZED" -name "$ex" 2>/dev/null | grep -q .; then
        echo "FAIL: excluded file $ex found in output"
        fail=1
    fi
done

if find "$MATERIALIZED/$DIR" -name 'SKILL.md' 2>/dev/null | grep -q .; then
    echo "FAIL: SKILL.md found in output (V17 violation)"
    fail=1
fi

manifest="$MATERIALIZED/$DIR/.mkset.json"
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
