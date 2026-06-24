#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for set/lib/mk-set.sh -- orchestrates emit-skill.sh per
# category, copies concepts, and installs bin/sync-set.

setup() {
    bats_require_minimum_version 1.5.0
    out="$(mktemp -d)"
    SKILLS_DIR="$(mktemp -d)"
    CONCEPTS_DIR="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/mk-set.sh"
    EMIT="$BATS_TEST_DIRNAME/../set/lib/emit-skill.sh"
    SYNC_SRC="$BATS_TEST_DIRNAME/../set/lib/sync-set.sh"

    mkdir -p "$SKILLS_DIR/demo"
    printf '# Demo\n\nDemo rule.\n' >"$SKILLS_DIR/demo.md"
    printf '# Demo: sub\n\nSub rule.\n' >"$SKILLS_DIR/demo/sub.md"

    export out SKILLS_DIR CONCEPTS_DIR EMIT SYNC_SRC
    export DIR=".claude/rules/set"
    export COND_FIELD="paths"
    export CONCEPTS="0"
    export EXCLUDE=""
}

teardown() {
    rm -rf "$out" "$SKILLS_DIR" "$CONCEPTS_DIR"
}

@test "emits category files as path-scoped rules" {
    export CATEGORIES="demo"
    export GLOBS_MAP="demo=**/*.nix,flake.lock"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$out/$DIR/demo.md" ]
    [ -f "$out/$DIR/demo/sub.md" ]
    grep -q 'paths:' "$out/$DIR/demo.md"
    grep -q '"**/*.nix"' "$out/$DIR/demo.md"
    grep -q 'Demo rule.' "$out/$DIR/demo.md"
    grep -q 'Sub rule.' "$out/$DIR/demo/sub.md"
}

@test "emits broad-glob category with paths" {
    export CATEGORIES="demo"
    export GLOBS_MAP="demo=**/*"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$out/$DIR/demo.md" ]
    [ -f "$out/$DIR/demo/sub.md" ]
    grep -q 'paths:' "$out/$DIR/demo.md"
    grep -q '"**/*"' "$out/$DIR/demo.md"
}

@test "copies concepts when CONCEPTS=1" {
    printf '# User\n\nUser concept.\n' >"$CONCEPTS_DIR/user.md"
    mkdir -p "$CONCEPTS_DIR/hw"
    printf '# HW\n\nHW concept.\n' >"$CONCEPTS_DIR/hw/box.md"
    export CATEGORIES="" GLOBS_MAP="" CONCEPTS="1"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$out/$DIR/concepts-user.md" ]
    [ -f "$out/$DIR/concepts-hw-box.md" ]
}

@test "skips concepts when CONCEPTS=0" {
    printf '# User\n' >"$CONCEPTS_DIR/user.md"
    export CATEGORIES="" GLOBS_MAP="" CONCEPTS="0"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    run ! ls "$out/$DIR"/concepts-*.md 2>/dev/null
}

@test "installs bin/sync-set from SYNC_SRC" {
    export CATEGORIES="" GLOBS_MAP=""
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$out/bin/sync-set" ]
    [ -x "$out/bin/sync-set" ]
}

@test "handles multiple categories" {
    mkdir -p "$SKILLS_DIR/extra"
    printf '# Extra\n\nExtra rule.\n' >"$SKILLS_DIR/extra.md"
    printf '# Extra: a\n\nA rule.\n' >"$SKILLS_DIR/extra/a.md"
    export CATEGORIES="demo extra"
    export GLOBS_MAP="demo=*.nix;extra=**/*"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$out/$DIR/demo.md" ]
    [ -f "$out/$DIR/demo/sub.md" ]
    [ -f "$out/$DIR/extra.md" ]
    [ -f "$out/$DIR/extra/a.md" ]
}
