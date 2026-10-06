#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/lint-badge-order.sh"
}

teardown() { rm -rf "$TMP"; }

@test "README with ordered linked badges and CI passes" {
    mkdir -p "$TMP/.github/workflows"
    : >"$TMP/.github/workflows/ci.yml"
    printf '%s\n' '[![CI](ci.svg)](ci.yml) [![License: MIT](license.svg)](LICENSE) [![NixOS 25.11](nix.svg)](https://nixos.org) [![Docs](docs.svg)](docs)' >"$TMP/README.md"
    run bash "$SCRIPT" "$TMP/README.md"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "license before CI is a finding" {
    mkdir -p "$TMP/.github/workflows"
    : >"$TMP/.github/workflows/ci.yml"
    printf '%s\n' '[![License: MIT](license.svg)](LICENSE) [![CI](ci.svg)](ci.yml) [![NixOS 25.11](nix.svg)](https://nixos.org)' >"$TMP/README.md"
    run bash "$SCRIPT" "$TMP/README.md"
    [ "$status" -ne 0 ]
    [[ "$output" == *"out of order"* && "$output" == *"corrected badge order"* ]]
}

@test "near-miss prose image is not treated as a badge" {
    printf '%s\n' 'A screenshot: ![architecture](diagram.png)' >"$TMP/README.md"
    run bash "$SCRIPT" "$TMP/README.md"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "workflow without CI badge is a finding" {
    mkdir -p "$TMP/.github/workflows"
    : >"$TMP/.github/workflows/ci.yml"
    printf '%s\n' '# Project' >"$TMP/README.md"
    run bash "$SCRIPT" "$TMP/README.md"
    [ "$status" -ne 0 ]
    [[ "$output" == *"no CI badge"* ]]
}
