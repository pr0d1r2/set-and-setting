#!/usr/bin/env bats

# Unit tests for lib/coverage-drift-check.sh -- the comparator extracted
# from mk-coverage-drift-check.nix. Contract: the expected set is the
# pinned check names plus the commands in the standard's emitted hook; the
# actual set adds the consumer's own hook commands and repo-local checks.
# Missing entries exit 1; extra entries are reported and allowed.

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/coverage-drift-check.sh"
    printf 'pre-commit:\n  commands:\n    alpha:\n      run: a\n    beta:\n      run: b\n' \
        >"$TMP/expected.yml"
    export EXPECTED_HOOK="$TMP/expected.yml"
    export ACTUAL_HOOK="$TMP/expected.yml"
    export EXPECTED_PINNED="nixfmt"
    export CONSUMER_CHECKS=""
    export FRAGMENTS="base nix"
}

teardown() {
    rm -rf "$TMP"
}

@test "exit 0 and PASS when the emitted hook carries every expected check" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"coverage-drift: PASS"* ]]
}

@test "exit 1 naming the check the consumer's hook does not emit" {
    printf 'pre-commit:\n  commands:\n    alpha:\n      run: a\n' >"$TMP/actual.yml"
    ACTUAL_HOOK="$TMP/actual.yml" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"missing emitted checks"* ]]
    [[ "$output" == *"beta"* ]]
}

@test "a repo-local check is reported as allowed, not missing" {
    CONSUMER_CHECKS="house-style" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"repo-local checks (allowed)"* ]]
    [[ "$output" == *"house-style"* ]]
}

@test "a pinned check absent from both hooks is still expected" {
    # EXPECTED_PINNED lands in both sets, so a pinned name never reads as
    # drift on its own -- the emitted hooks are what differ.
    EXPECTED_PINNED="nixfmt
statix" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"coverage-drift: PASS"* ]]
}
