#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031  # per-@test env vars; bats runs each in its own process

# Unit tests for set/lib/emit-skill.sh -- emits one category's
# Agent-Skills file from agnostic source markdown.

setup() {
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

@test "conditional skill: frontmatter + globs + folded body" {
    export CAT=demo DEST="$DESTDIR/SKILL.md" GLOBS="**/*.nix flake.lock"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run cat "$DESTDIR/SKILL.md"
    [[ "$output" == *"name: demo"* ]]
    [[ "$output" == *"description: \"Demo -- Demo core rule."* ]]
    [[ "$output" == *"paths:"* ]]
    [[ "$output" == *"- \"**/*.nix\""* ]]
    [[ "$output" == *"Demo core rule."* ]]
    [[ "$output" == *"Aspect rule."* ]]
}

@test "always-on rule: no globs field when GLOBS empty" {
    export CAT=demo DEST="$DESTDIR/demo.md" GLOBS=""
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run cat "$DESTDIR/demo.md"
    [[ "$output" == *"name: demo"* ]]
    [[ "$output" != *"paths:"* ]]
}

@test "exclude omits a file from the body" {
    printf '# Secret\n\nSHOULD_NOT_APPEAR\n' >"$SKILLS_DIR/demo/secret.md"
    export CAT=demo DEST="$DESTDIR/SKILL.md" GLOBS="**/*.nix" EXCLUDE="secret.md"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run cat "$DESTDIR/SKILL.md"
    [[ "$output" != *"SHOULD_NOT_APPEAR"* ]]
}

@test "falls back to category name when source has no heading" {
    mkdir -p "$SKILLS_DIR/bare"
    printf 'no heading here\n' >"$SKILLS_DIR/bare/x.md"
    export CAT=bare DEST="$DESTDIR/bare.md" GLOBS=""
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q 'name: bare' "$DESTDIR/bare.md"
}
