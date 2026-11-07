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

@test "nested env timeout does not satisfy a command" {
    printf '%s\n' 'pre-commit:' '  commands:' '    nested:' '      run: tool' '      env:' '        timeout: 30s' >"$TMP/nested.yml"
    run bash "$SCRIPT" "$TMP/nested.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == "$TMP/nested.yml:3: command nested has no bounding timeout (add a timeout key or wrap its invocation with timeout)" ]]
}

@test "empty command timeout does not satisfy a command" {
    printf '%s\n' 'pre-commit:' '  commands:' '    empty:' '      run: tool' '      timeout:' >"$TMP/empty.yml"
    run bash "$SCRIPT" "$TMP/empty.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == "$TMP/empty.yml:3: command empty has no bounding timeout (add a timeout key or wrap its invocation with timeout)" ]]
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

@test "timeout in a block scalar shell comment does not satisfy a command" {
    printf '%s\n' 'pre-commit:' '  commands:' '    hanging:' '      run: |' '        tool' '        # timeout 30 tool' >"$TMP/block-near-miss.yml"
    run bash "$SCRIPT" "$TMP/block-near-miss.yml"
    [ "$status" -eq 1 ]
}

@test "later command fields do not satisfy a command timeout" {
    printf '%s\n' 'pre-commit:' '  commands:' '    hanging:' '      run: tool' '      glob: "*.sh" # timeout needed' >"$TMP/later-field.yml"
    run bash "$SCRIPT" "$TMP/later-field.yml"
    [ "$status" -eq 1 ]
    [[ "$output" == "$TMP/later-field.yml:3: command hanging has no bounding timeout (add a timeout key or wrap its invocation with timeout)" ]]
}
