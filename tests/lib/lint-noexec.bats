#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/lint-noexec.sh"
}

teardown() { rm -rf "$TMP"; }

@test "clean fixture passes" {
    printf '%s\n' '#!/usr/bin/env bash' 'bash scripts/x.sh' 'echo "./docs/example.sh is documentation"' >"$TMP/clean.sh"
    run bash "$SCRIPT" "$TMP/clean.sh"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "unprefixed shell script invocations are findings" {
    printf '%s\n' './scripts/x.sh' 'run ./other/y.sh' >"$TMP/bad.sh"
    run bash "$SCRIPT" "$TMP/bad.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/bad.sh:1: invoke shell scripts with an interpreter prefix: bash ./scripts/x.sh"* ]]
    [[ "$output" == *"$TMP/bad.sh:2: invoke shell scripts with an interpreter prefix: bash ./other/y.sh"* ]]
}

@test "shebangs and quoted documentation are not findings" {
    printf '%s\n' '#!/bin/bash' 'message: "run ./scripts/x.sh from the docs"' 'description: \047./scripts/y.sh\047' >"$TMP/near-miss.yml"
    run bash "$SCRIPT" "$TMP/near-miss.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
