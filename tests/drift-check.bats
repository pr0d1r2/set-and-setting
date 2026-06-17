#!/usr/bin/env bats

# Unit tests for lib/drift-check.sh -- the generic drift comparator
# extracted from mk-drift-check.nix / mk-setting-drift-check.nix.
# Contract: diff EXPECTED vs ACTUAL over REL_PATHS; exit 0 on match,
# 1 on drift or missing path; print SYNC_HINT on failure.

setup() {
    EXPECTED="$(mktemp -d)"
    ACTUAL="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/drift-check.sh"
    export EXPECTED ACTUAL
    export SYNC_HINT="run sync"
}

teardown() {
    rm -rf "$EXPECTED" "$ACTUAL"
}

@test "exit 0 and 'no drift' when paths identical" {
    echo same >"$EXPECTED/a.md"
    echo same >"$ACTUAL/a.md"
    REL_PATHS="a.md" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"no drift"* ]]
}

@test "exit 1 and 'DRIFT DETECTED' when content differs" {
    echo expected >"$EXPECTED/a.md"
    echo actual >"$ACTUAL/a.md"
    REL_PATHS="a.md" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"DRIFT DETECTED"* ]]
    [[ "$output" == *"run sync"* ]]
}

@test "exit 1 and 'MISSING' when actual lacks an expected path" {
    echo expected >"$EXPECTED/a.md"
    REL_PATHS="a.md" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"MISSING"* ]]
}

@test "compares directories recursively" {
    mkdir -p "$EXPECTED/d" "$ACTUAL/d"
    echo x >"$EXPECTED/d/f.md"
    echo y >"$ACTUAL/d/f.md"
    REL_PATHS="d" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
}

@test "ignores expected paths that do not exist in EXPECTED" {
    REL_PATHS="absent.md" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}
