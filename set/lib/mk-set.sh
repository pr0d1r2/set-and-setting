#!/usr/bin/env bash
# Orchestrate the set emitter (extracted from mk-set.nix). Loops the
# selected categories, invokes emit-skill.sh per category to mirror
# source files as path-scoped rules; copies concepts; installs
# bin/sync-set. No functions (sh/modularity).
# Env in: out, SKILLS_DIR, CONCEPTS_DIR, CONCEPTS (0/1), DIR,
#   COND_FIELD, CATEGORIES, GLOBS_MAP (cat=g1,g2;cat2=g3),
#   EXCLUDE, EMIT (emit-skill.sh path), SYNC_SRC (sync-set.sh path).
# shellcheck disable=SC2154  # $out is provided by the nix runCommand env
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
        SKILLS_DIR="$SKILLS_DIR" EXCLUDE="$EXCLUDE" bash "$EMIT"
done

if [ "$CONCEPTS" = "1" ]; then
    mkdir -p "$out/$DIR"
    find "$CONCEPTS_DIR" -name '*.md' | sort | while read -r f; do
        rel="${f#"$CONCEPTS_DIR"/}"
        cp "$f" "$out/$DIR/concepts-${rel//\//-}"
    done
fi

mkdir -p "$out/bin"
cp "$SYNC_SRC" "$out/bin/sync-set"
chmod +x "$out/bin/sync-set"
