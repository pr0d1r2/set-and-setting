#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/lint-watch-file.sh"
    mkdir -p "$TMP/lib"
    printf '%s\n' 'use flake' >"$TMP/.envrc"
    printf '%s\n' 'text = builtins.readFile ./lib/tool.sh;' >"$TMP/check.nix"
    printf '%s\n' '#!/usr/bin/env bash' >"$TMP/lib/tool.sh"
}

teardown() {
    rm -rf "$TMP"
}

@test "a covered shell script passes" {
    printf '%s\n' 'watch_file lib/tool.sh' >>"$TMP/.envrc"
    cd "$TMP"
    run bash "$SCRIPT" check.nix
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "an uncovered shell script is a finding" {
    cd "$TMP"
    run bash "$SCRIPT" check.nix
    [ "$status" -eq 1 ]
    [[ "$output" == *"check.nix:1: add \`watch_file lib/tool.sh\` to .envrc"* ]]
}

@test "a shell path that is not readFile is not a finding" {
    printf '%s\n' 'script = ./lib/tool.sh;' >"$TMP/check.nix"
    cd "$TMP"
    run bash "$SCRIPT" check.nix
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
