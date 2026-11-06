#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/fragment-lint-timeout.sh"
}

teardown() { rm -rf "$TMP"; }

@test "commands with explicit or invocation timeouts pass" {
    printf '%s\n' 'pre-commit:' '  commands:' '    keyed:' '      run: tool' '      timeout: 30s' '    wrapped:' '      run: timeout 30 tool' >"$TMP/clean.yml"
    run bash "$SCRIPT" "$TMP/clean.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "command without a timeout is reported" {
    printf '%s\n' 'pre-commit:' '  commands:' '    hanging:' '      run: tool' >"$TMP/bad.yml"
    run bash "$SCRIPT" "$TMP/bad.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == "$TMP/bad.yml:3: command hanging has no bounding timeout (add a timeout key or wrap its invocation with timeout)" ]]
}

@test "an explicit repository default satisfies commands" {
    printf '%s\n' 'default_timeout: 30s' 'pre-push:' '  commands:' '    hanging:' '      run: tool' >"$TMP/default.yml"
    run bash "$SCRIPT" "$TMP/default.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "timeout in documentation does not satisfy a command" {
    printf '%s\n' 'pre-commit:' '  commands:' '    hanging:' '      run: tool # timeout is documented elsewhere' >"$TMP/near-miss.yml"
    run bash "$SCRIPT" "$TMP/near-miss.yml"
    [ "$status" -eq 1 ]
}
