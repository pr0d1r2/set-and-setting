#!/usr/bin/env bats

setup() {
    bats_require_minimum_version 1.5.0
    ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "minimal set flake exposes mkSet without lefthook inputs" {
    run nix flake metadata --json --no-write-lock-file "$ROOT/set"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"nixpkgs"'* ]]
    [[ "$output" != *'nix-lefthook-'* ]]
}

@test "minimal set flake evaluates lib.mkSet" {
    run nix eval "$ROOT/set#lib.mkSet"
    [ "$status" -eq 0 ]
    [[ "$output" == *"lambda"* ]]
}
