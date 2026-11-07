#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/ci-lint-sha.sh"
}

teardown() { rm -rf "$TMP"; }

@test "full SHAs and local reusable workflows are clean" {
    printf '%s\n' \
        'jobs:' \
        '  check:' \
        '    uses: ./.github/workflows/guardrails.yml' \
        '  steps:' \
        '    - uses: actions/checkout@0123456789abcdef0123456789abcdef01234567' >"$TMP/clean.yml"
    run bash "$SCRIPT" "$TMP/clean.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "tags branches and short SHAs are findings" {
    printf '%s\n' \
        'steps:' \
        '  - uses: actions/checkout@v4' \
        '  - uses: actions/setup-node@main' \
        '  - uses: actions/cache@fbeb9d9' >"$TMP/violating.yml"
    run bash "$SCRIPT" "$TMP/violating.yml"
    [ "$status" -eq 1 ]
    [ "$(printf '%s\n' "$output" | grep -c "$TMP/violating.yml:")" -eq 3 ]
    [[ "$output" == *"git ls-remote https://github.com/owner/repo refs/heads/main"* ]]
}

@test "a near-miss that is not a uses key is ignored" {
    printf '%s\n' \
        'description: "uses: actions/checkout@v4"' \
        '# uses: actions/setup-node@main' >"$TMP/near-miss.yml"
    run bash "$SCRIPT" "$TMP/near-miss.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "the shipped scaffold pins actions and uses the reusable workflow branch" {
    run bash "$SCRIPT" "$BATS_TEST_DIRNAME/../../setting/scaffold/ci.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    grep -q 'uses: pr0d1r2/set-and-setting/.github/workflows/guardrails.yml@main' \
        "$BATS_TEST_DIRNAME/../../setting/scaffold/leaf-ci.yml"
}

@test "the canonical leaf guardrails caller is allowed to follow main" {
    printf '%s\n' \
        'jobs:' \
        '  guardrails:' \
        '    uses: pr0d1r2/set-and-setting/.github/workflows/guardrails.yml@main' >"$TMP/leaf.yml"
    run bash "$SCRIPT" "$TMP/leaf.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
