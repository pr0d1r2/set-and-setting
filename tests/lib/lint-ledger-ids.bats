#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/lint-ledger-ids.sh"
}

teardown() {
    rm -rf "$TMP"
}

@test "clean ledger passes" {
    printf '%s\n' '| B1 | date | finding | fix |' '| T2 | date | task | status |' >"$TMP/SPEC.md"
    run bash "$SCRIPT" "$TMP/SPEC.md"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "duplicate B id is a finding" {
    printf '%s\n' '| B1 | first | | |' '| B1 | second | | |' >"$TMP/SPEC.md"
    run bash "$SCRIPT" "$TMP/SPEC.md"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/SPEC.md:2: duplicate ledger id B1"* ]]
}

@test "duplicate T id is a finding" {
    printf '%s\n' '| T1 | first | | |' '| T1 | second | | |' >"$TMP/SPEC.md"
    run bash "$SCRIPT" "$TMP/SPEC.md"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/SPEC.md:2: duplicate ledger id T1"* ]]
}

@test "a gap is not a finding" {
    printf '%s\n' '| B1 | first | | |' '| B3 | third | | |' >"$TMP/SPEC.md"
    run bash "$SCRIPT" "$TMP/SPEC.md"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
