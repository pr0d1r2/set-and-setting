#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031  # per-@test env vars; bats runs each in its own process

# Unit tests for set/lib/emit-skill.sh -- emits one category's
# Agent-Skills file from agnostic source markdown. Domain categories
# (with GLOBS) emit facets-as-linked-files (V25); always-on categories
# (no GLOBS) concatenate into a single rule.

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    DESTDIR="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skill.sh"
    mkdir -p "$SKILLS_DIR/demo"
    printf '# Demo\n\nDemo core rule.\n' >"$SKILLS_DIR/demo.md"
    printf '# Demo: aspect\n\nAspect rule.\n' >"$SKILLS_DIR/demo/aspect.md"
    export SKILLS_DIR COND_FIELD=paths EXCLUDE=""
}

teardown() {
    rm -rf "$SKILLS_DIR" "$DESTDIR"
}

@test "conditional skill: frontmatter + globs + linked facets" {
    export CAT=demo DEST="$DESTDIR/demo/SKILL.md" GLOBS="**/*.nix flake.lock"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run cat "$DESTDIR/demo/SKILL.md"
    [[ "$output" == *"name: demo"* ]]
    [[ "$output" == *"description: \"Demo -- Demo core rule."* ]]
    [[ "$output" == *"paths:"* ]]
    [[ "$output" == *"- \"**/*.nix\""* ]]
    [[ "$output" == *"Demo core rule."* ]]
    [[ "$output" == *"[Demo: aspect](aspect.md)"* ]]
    # facet heading not concatenated as standalone content
    run ! grep -q '^# Demo: aspect' "$DESTDIR/demo/SKILL.md"
}

@test "conditional skill: facet file cloned raw alongside SKILL.md" {
    export CAT=demo DEST="$DESTDIR/demo/SKILL.md" GLOBS="**/*.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$DESTDIR/demo/aspect.md" ]
    grep -q 'Aspect rule.' "$DESTDIR/demo/aspect.md"
    run head -1 "$DESTDIR/demo/aspect.md"
    [[ "$output" == "# Demo: aspect" ]]
}

@test "conditional skill: facet link carries one-line note" {
    export CAT=demo DEST="$DESTDIR/demo/SKILL.md" GLOBS="**/*.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q '\[Demo: aspect\](aspect.md) -- Aspect rule\.' "$DESTDIR/demo/SKILL.md"
}

@test "conditional skill: nested facets preserve path structure" {
    mkdir -p "$SKILLS_DIR/deep/sub"
    printf '# Deep\n\nDeep rule.\n' >"$SKILLS_DIR/deep.md"
    printf '# Deep: top\n\nTop facet.\n' >"$SKILLS_DIR/deep/top.md"
    printf '# Deep: sub nested\n\nNested facet.\n' >"$SKILLS_DIR/deep/sub/nested.md"
    export CAT=deep DEST="$DESTDIR/deep/SKILL.md" GLOBS="**/*.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q '\[Deep: sub nested\](sub/nested.md)' "$DESTDIR/deep/SKILL.md"
    grep -q '\[Deep: top\](top.md)' "$DESTDIR/deep/SKILL.md"
    [ -f "$DESTDIR/deep/top.md" ]
    [ -f "$DESTDIR/deep/sub/nested.md" ]
}

@test "conditional skill without core: body is links only" {
    rm "$SKILLS_DIR/demo.md"
    export CAT=demo DEST="$DESTDIR/demo/SKILL.md" GLOBS="**/*.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q '\[Demo: aspect\](aspect.md)' "$DESTDIR/demo/SKILL.md"
    run cat "$DESTDIR/demo/SKILL.md"
    [[ "$output" != *"Demo core rule."* ]]
}

@test "always-on rule: no globs field, body concatenated" {
    export CAT=demo DEST="$DESTDIR/demo.md" GLOBS=""
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run cat "$DESTDIR/demo.md"
    [[ "$output" == *"name: demo"* ]]
    [[ "$output" != *"paths:"* ]]
    [[ "$output" == *"Demo core rule."* ]]
    [[ "$output" == *"Aspect rule."* ]]
}

@test "exclude omits file from links and facets" {
    printf '# Secret\n\nSHOULD_NOT_APPEAR\n' >"$SKILLS_DIR/demo/secret.md"
    export CAT=demo DEST="$DESTDIR/demo/SKILL.md" GLOBS="**/*.nix" EXCLUDE="secret.md"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run cat "$DESTDIR/demo/SKILL.md"
    [[ "$output" != *"SHOULD_NOT_APPEAR"* ]]
    [[ "$output" != *"secret.md"* ]]
    [ ! -f "$DESTDIR/demo/secret.md" ]
}

@test "falls back to category name when source has no heading" {
    mkdir -p "$SKILLS_DIR/bare"
    printf 'no heading here\n' >"$SKILLS_DIR/bare/x.md"
    export CAT=bare DEST="$DESTDIR/bare.md" GLOBS=""
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q 'name: bare' "$DESTDIR/bare.md"
}
