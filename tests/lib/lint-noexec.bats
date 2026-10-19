#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/lint-noexec.sh"
}

teardown() { rm -rf "$TMP"; }

@test "clean fixture passes" {
    printf '%s\n' '#!/usr/bin/env bash' 'bash scripts/x.sh' 'sh -c . sh repo/config.sh' 'echo "./docs/example.sh is documentation"' >"$TMP/clean.sh"
    run bash "$SCRIPT" "$TMP/clean.sh"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "unprefixed shell script invocations are findings" {
    printf '%s\n' './scripts/x.sh' 'run ./other/y.sh' 'script.sh' >"$TMP/bad.sh"
    run bash "$SCRIPT" "$TMP/bad.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"$TMP/bad.sh:1: invoke shell scripts with an interpreter prefix: bash ./scripts/x.sh"* ]]
    [[ "$output" == *"$TMP/bad.sh:2: invoke shell scripts with an interpreter prefix: bash ./other/y.sh"* ]]
    [[ "$output" == *"$TMP/bad.sh:3: invoke shell scripts with an interpreter prefix: bash script.sh"* ]]
}

@test "shebangs and quoted documentation are not findings" {
    printf '%s\n' '#!/bin/bash' 'message: "run ./scripts/x.sh from the docs"' 'description: \047./scripts/y.sh\047' >"$TMP/near-miss.yml"
    run bash "$SCRIPT" "$TMP/near-miss.yml"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "non-invocation path-like words are ignored" {
    cat >"$TMP/examples.nix" <<'EOF'
value = builtins.readFile ../script.sh;
EOF
    cat >"$TMP/examples.sh" <<'EOF'
watch_file dev.sh
source_env .envrc
for wrapper in agent-one.sh agent-two.sh; do echo "$wrapper"; done
EOF
    run bash "$SCRIPT" "$TMP/examples.nix" "$TMP/examples.sh"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "direct invocations remain findings near shell constructs" {
    printf '%s\n' 'for wrapper in one.sh; do' './scripts/run.sh' 'done' >"$TMP/direct.sh"
    run bash "$SCRIPT" "$TMP/direct.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *":2: invoke shell scripts with an interpreter prefix: bash ./scripts/run.sh"* ]]
}
