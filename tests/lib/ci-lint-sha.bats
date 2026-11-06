#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/ci-lint-sha.sh"
    mkdir -p "$TMP/.github/workflows"
}

teardown() { rm -rf "$TMP"; }

@test "full SHA and local reusable workflow pass" {
    printf '%s\n' \
        'jobs:' \
        '  check:' \
        '    uses: ./.github/workflows/guardrails.yml' \
        '    steps:' \
        '      - uses: owner/action@0123456789abcdef0123456789abcdef01234567' >"$TMP/.github/workflows/clean.yml"
    run bash "$SCRIPT" "$TMP/.github/workflows/clean.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "tag branch and short SHA are findings" {
    printf '%s\n' \
        'jobs:' \
        '  check:' \
        '    steps:' \
        '      - uses: owner/tagged@v1' \
        '      - uses: owner/branched@main' \
        '      - uses: owner/short@fbeb9d9' >"$TMP/.github/workflows/violating.yml"
    run bash "$SCRIPT" "$TMP/.github/workflows/violating.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *":4: pin owner/tagged@v1 to a full 40-character commit SHA; resolve with: git ls-remote https://github.com/owner/tagged refs/heads/v1 (or refs/tags/v1)"* ]]
    [[ "$output" == *":5: pin owner/branched@main to a full 40-character commit SHA"* ]]
    [[ "$output" == *":6: pin owner/short@fbeb9d9 to a full 40-character commit SHA"* ]]
}

@test "quoted uses key and value are findings" {
    printf '%s\n' \
        'jobs:' \
        '  check:' \
        '    steps:' \
        "      - 'uses': 'owner/tagged@v1'" >"$TMP/.github/workflows/quoted.yml"
    run bash "$SCRIPT" "$TMP/.github/workflows/quoted.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *":4: pin owner/tagged@v1 to a full 40-character commit SHA"* ]]
}

@test "whitespace before uses colon is a finding" {
    printf '%s\n' \
        'jobs:' \
        '  check:' \
        '    steps:' \
        '      - uses : actions/checkout@v4' >"$TMP/.github/workflows/whitespace.yml"
    run bash "$SCRIPT" "$TMP/.github/workflows/whitespace.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *":4: pin actions/checkout@v4 to a full 40-character commit SHA"* ]]
}

@test "uses key in comment does not mask mutable ref" {
    printf '%s\n' \
        'jobs:' \
        '  check:' \
        '    steps:' \
        '      - uses: actions/checkout@v4 # "uses": ./safe' >"$TMP/.github/workflows/comment.yml"
    run bash "$SCRIPT" "$TMP/.github/workflows/comment.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *":4: pin actions/checkout@v4 to a full 40-character commit SHA"* ]]
}

@test "inline mapping uses keys are findings" {
    printf '%s\n' \
        'jobs:' \
        '  check:' \
        '    steps:' \
        '      - { name: checkout, uses: actions/checkout@v4 }' >"$TMP/.github/workflows/inline.yml"
    run bash "$SCRIPT" "$TMP/.github/workflows/inline.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == *":4: pin actions/checkout@v4 to a full 40-character commit SHA"* ]]
}

@test "near-miss outside workflow directory is ignored" {
    printf '%s\n' '      - uses: owner/action@v1' >"$TMP/example.yml"
    run bash "$SCRIPT" "$TMP/example.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
