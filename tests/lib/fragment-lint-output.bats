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

@test "comments after failure list values are ignored" {
    printf '%s\n' 'output:' '  - failure # show errors' >"$TMP/comment.yml"
    run bash "$SCRIPT" "$TMP/comment.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "hashes inside quoted output values are preserved" {
    printf '%s\n' 'output: [" # disallowed"]' >"$TMP/quoted-hash.yml"
    run bash "$SCRIPT" "$TMP/quoted-hash.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/quoted-hash.yml:1: output list contains ' # disallowed'"* ]]
}

@test "indentless output list is scanned" {
    printf '%s\n' 'output:' '- success' >"$TMP/indentless.yml"
    run bash "$SCRIPT" "$TMP/indentless.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/indentless.yml:2: output list contains 'success'"* ]]
}

@test "blank and comment lines within output list are ignored" {
    printf '%s\n' 'output:' '  - failure' '' '  # explain the allowed output' '  - success' >"$TMP/gapped.yml"
    run bash "$SCRIPT" "$TMP/gapped.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/gapped.yml:5: output list contains 'success'"* ]]
}

@test "non-failure output is a finding" {
    printf '%s\n' 'output: [failure, success]' >"$TMP/bad.yml"
    run bash "$SCRIPT" "$TMP/bad.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/bad.yml:1: output list contains 'success'"* ]]
}

@test "non-failure output in a multiline flow list is a finding" {
    printf '%s\n' 'output: [failure,' '  success]' >"$TMP/multiline.yml"
    run bash "$SCRIPT" "$TMP/multiline.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/multiline.yml:2: output list contains 'success'"* ]]
}

@test "brackets in multiline flow list comments are ignored" {
    printf '%s\n' 'output: [' '  # ] notes' '  success]' >"$TMP/comment-flow.yml"
    run bash "$SCRIPT" "$TMP/comment-flow.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/comment-flow.yml:3: output list contains 'success'"* ]]
}

@test "near-miss outside an output list is ignored" {
    printf '%s\n' 'message: "success is useful documentation"' 'other: [skips]' >"$TMP/near-miss.yml"
    run bash "$SCRIPT" "$TMP/near-miss.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
