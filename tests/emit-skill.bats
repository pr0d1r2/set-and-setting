#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031  # per-@test env vars; bats runs each in its own process

# Unit tests for set/lib/emit-skill.sh -- emits one category's
# path-scoped rule files from agnostic source markdown. Each source
# file is mirrored verbatim with the conditional-load field prepended
# as frontmatter (V17/V18/V19/V25).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    DEST_DIR="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skill.sh"
    mkdir -p "$SKILLS_DIR/demo"
    printf '# Demo\n\nDemo core rule.\n' >"$SKILLS_DIR/demo.md"
    printf '# Demo: aspect\n\nAspect rule.\n' >"$SKILLS_DIR/demo/aspect.md"
    export SKILLS_DIR COND_FIELD=paths EXCLUDE=""
    export EMIT_RULE="$BATS_TEST_DIRNAME/../set/lib/emit-rule.sh"
    export CORE="" OVERRIDES=""
}

teardown() {
    rm -rf "$SKILLS_DIR" "$DEST_DIR"
}

@test "emits core file as a path-scoped rule" {
    export CAT=demo DEST_DIR="$DEST_DIR" GLOBS="**/*.nix flake.lock"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$DEST_DIR/demo.md" ]
    grep -q '^paths:' "$DEST_DIR/demo.md"
    grep -q '"**/*.nix"' "$DEST_DIR/demo.md"
    grep -q '"flake.lock"' "$DEST_DIR/demo.md"
    grep -q 'Demo core rule.' "$DEST_DIR/demo.md"
}

@test "emits subdir files as individual path-scoped rules" {
    export CAT=demo DEST_DIR="$DEST_DIR" GLOBS="**/*.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$DEST_DIR/demo/aspect.md" ]
    grep -q '^paths:' "$DEST_DIR/demo/aspect.md"
    grep -q '"**/*.nix"' "$DEST_DIR/demo/aspect.md"
    grep -q 'Aspect rule.' "$DEST_DIR/demo/aspect.md"
}

@test "preserves verbatim body after frontmatter" {
    export CAT=demo DEST_DIR="$DEST_DIR" GLOBS="**/*.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    body="$(sed '1,/^---$/d' "$DEST_DIR/demo/aspect.md")"
    [[ "$body" == *"# Demo: aspect"* ]]
    [[ "$body" == *"Aspect rule."* ]]
}

@test "nested files preserve path structure" {
    mkdir -p "$SKILLS_DIR/deep/sub"
    printf '# Deep\n\nDeep rule.\n' >"$SKILLS_DIR/deep.md"
    printf '# Deep: top\n\nTop facet.\n' >"$SKILLS_DIR/deep/top.md"
    printf '# Deep: sub nested\n\nNested facet.\n' >"$SKILLS_DIR/deep/sub/nested.md"
    export CAT=deep DEST_DIR="$DEST_DIR" GLOBS="**/*.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$DEST_DIR/deep.md" ]
    [ -f "$DEST_DIR/deep/top.md" ]
    [ -f "$DEST_DIR/deep/sub/nested.md" ]
    grep -q 'Top facet.' "$DEST_DIR/deep/top.md"
    grep -q 'Nested facet.' "$DEST_DIR/deep/sub/nested.md"
}

@test "category without core: only subdir files emitted" {
    rm "$SKILLS_DIR/demo.md"
    export CAT=demo DEST_DIR="$DEST_DIR" GLOBS="**/*.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ ! -f "$DEST_DIR/demo.md" ]
    [ -f "$DEST_DIR/demo/aspect.md" ]
}

@test "broad globs for cross-cutting categories" {
    export CAT=demo DEST_DIR="$DEST_DIR" GLOBS="**/*"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q '"**/*"' "$DEST_DIR/demo.md"
    grep -q '"**/*"' "$DEST_DIR/demo/aspect.md"
}

@test "exclude omits file from output" {
    printf '# Secret\n\nSHOULD_NOT_APPEAR\n' >"$SKILLS_DIR/demo/secret.md"
    export CAT=demo DEST_DIR="$DEST_DIR" GLOBS="**/*.nix" EXCLUDE="secret.md"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ ! -f "$DEST_DIR/demo/secret.md" ]
    [ -f "$DEST_DIR/demo/aspect.md" ]
}

@test "exclude of core file prevents its emission" {
    export CAT=demo DEST_DIR="$DEST_DIR" GLOBS="**/*.nix" EXCLUDE="demo.md"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ ! -f "$DEST_DIR/demo.md" ]
    [ -f "$DEST_DIR/demo/aspect.md" ]
}

@test "no SKILL.md generated" {
    export CAT=demo DEST_DIR="$DEST_DIR" GLOBS="**/*.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ ! -f "$DEST_DIR/demo/SKILL.md" ]
}
