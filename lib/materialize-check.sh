#!/usr/bin/env bash
# Verify that mkSet materialization produces the expected multi-channel
# layout for the requested categories (V17/V18/V19/V25/V30). The channel
# is decided by the meta map: a core category emits path-less rules (no
# conditional field -> always-on, V18/V32); a domain category emits rules
# carrying the conditional-load field + its globs (V19). A per-file
# override (meta.channelOverrides) can flip a single file. Assertions
# self-derive from categories.nix (GLOBS_MAP + CORE) and meta (OVERRIDES).
# Extracted per nix/modularity + sh/modularity.
# Env in:
#   MATERIALIZED  path to the mkSet output tree
#   DIR           agent rules dir (e.g. .claude/rules/set)
#   COND_FIELD    frontmatter field name (e.g. paths)
#   CATEGORIES    space-separated categories that were requested
#   GLOBS_MAP     semicolon-separated cat=g1,g2;cat2=g3
#   CORE          space-separated core (always-on) category names
#   OVERRIDES     per-file overrides: "path<TAB>channel<TAB>g1,g2" lines
#   EXCLUDE       space-separated filenames that were excluded
set -euo pipefail

read -ra cats <<<"${CATEGORIES:-}"
IFS=';' read -ra mapentries <<<"${GLOBS_MAP:-}"
read -ra excludes <<<"${EXCLUDE:-}"

fail=0

# assert_rule <relpath> <file> <category-channel> <raw-globs-csv>
# inlined twice below (no functions, sh/modularity) -- once for the core
# file, once per tree file.

for cat in "${cats[@]:-}"; do
    [ -n "$cat" ] || continue

    raw_globs=""
    for entry in "${mapentries[@]:-}"; do
        if [ "${entry%%=*}" = "$cat" ]; then
            raw_globs="${entry#*=}"
            break
        fi
    done

    cat_channel="domain"
    for c in ${CORE:-}; do
        [ "$c" = "$cat" ] && cat_channel="core" && break
    done

    catdir="$MATERIALIZED/$DIR/$cat"
    corefile="$MATERIALIZED/$DIR/$cat.md"
    has_files=0

    if [ -f "$corefile" ]; then
        has_files=1
        rel="$cat.md"
        channel="$cat_channel"
        globs="$raw_globs"
        while IFS=$'\t' read -r opath ochannel oglobs; do
            [ "$opath" = "$rel" ] || continue
            [ -n "$ochannel" ] && channel="$ochannel"
            [ -n "$oglobs" ] && globs="$oglobs"
            break
        done <<<"${OVERRIDES:-}"

        if [ "$channel" = "core" ]; then
            grep -q "^${COND_FIELD}:" "$corefile" && {
                echo "FAIL: core $rel must be path-less"
                fail=1
            }
        else
            grep -q "^${COND_FIELD}:" "$corefile" || {
                echo "FAIL: $rel missing $COND_FIELD frontmatter"
                fail=1
            }
            if [ -n "$globs" ]; then
                IFS=',' read -ra expected_globs <<<"$globs"
                for g in "${expected_globs[@]}"; do
                    grep -qF "\"$g\"" "$corefile" || {
                        echo "FAIL: $rel missing glob \"$g\""
                        fail=1
                    }
                done
            fi
        fi
    fi

    if [ -d "$catdir" ]; then
        has_files=1
        while IFS= read -r rule; do
            [ -n "$rule" ] || continue
            relname="${rule#"$catdir"/}"
            rel="$cat/$relname"
            channel="$cat_channel"
            globs="$raw_globs"
            while IFS=$'\t' read -r opath ochannel oglobs; do
                [ "$opath" = "$rel" ] || continue
                [ -n "$ochannel" ] && channel="$ochannel"
                [ -n "$oglobs" ] && globs="$oglobs"
                break
            done <<<"${OVERRIDES:-}"

            if [ "$channel" = "core" ]; then
                grep -q "^${COND_FIELD}:" "$rule" && {
                    echo "FAIL: core $rel must be path-less"
                    fail=1
                }
            else
                grep -q "^${COND_FIELD}:" "$rule" || {
                    echo "FAIL: $rel missing $COND_FIELD frontmatter"
                    fail=1
                }
                if [ -n "$globs" ]; then
                    IFS=',' read -ra expected_globs <<<"$globs"
                    for g in "${expected_globs[@]}"; do
                        grep -qF "\"$g\"" "$rule" || {
                            echo "FAIL: $rel missing glob \"$g\""
                            fail=1
                        }
                    done
                fi
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
