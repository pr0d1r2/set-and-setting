#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/fragment-lint-output.sh"
}

teardown() { rm -rf "$TMP"; }

@test "clean failure-only output passes" {
    printf '%s\n' 'output: [failure]' >"$TMP/clean.yml"
    run bash "$SCRIPT" "$TMP/clean.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "non-failure output is a finding" {
    printf '%s\n' 'output: [failure, success]' >"$TMP/bad.yml"
    run bash "$SCRIPT" "$TMP/bad.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/bad.yml:1: output list contains 'success'"* ]]
}

@test "near-miss outside an output list is ignored" {
    printf '%s\n' 'message: "success is useful documentation"' 'other: [skips]' >"$TMP/near-miss.yml"
    run bash "$SCRIPT" "$TMP/near-miss.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
