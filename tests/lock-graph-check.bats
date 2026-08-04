#!/usr/bin/env bats

setup() {
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/lock-graph-check.sh"
}

teardown() {
    rm -rf "$TARGET"
}

write_lock() {
    printf '{"nodes":{%s},"root":"root","version":7}\n' "$1" >"$TARGET/flake.lock"
}

@test "accepts unique clean foundation pins" {
    write_lock '"nixpkgs":{"locked":{"owner":"NixOS","repo":"nixpkgs"}},"nixpkgs-lock":{"locked":{"owner":"pr0d1r2","repo":"nixpkgs-lock"},"inputs":{"nixpkgs":"nixpkgs"}},"root":{"inputs":{"nixpkgs-lock":"nixpkgs-lock"}}'
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "rejects duplicate foundation pins" {
    write_lock '"nixpkgs":{"locked":{"owner":"NixOS","repo":"nixpkgs"}},"nixpkgs_2":{"locked":{"owner":"NixOS","repo":"nixpkgs"}},"root":{"inputs":{}}'
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"nixpkgs has 2 lock nodes"* ]]
}

@test "rejects a check input with its own nixpkgs node" {
    write_lock '"check":{"locked":{"owner":"pr0d1r2","repo":"nix-lefthook-example"},"inputs":{"nixpkgs":"nixpkgs_2"}},"nixpkgs":{"locked":{"owner":"NixOS","repo":"nixpkgs"}},"nixpkgs_2":{"locked":{"owner":"NixOS","repo":"nixpkgs"}},"root":{"inputs":{"check":"check","nixpkgs":"nixpkgs"}}'
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"nixpkgs has 2 lock nodes"* ]]
    [[ "$output" == *"shared inputs must use follows"* ]]
}

@test "rejects a poisoned nixpkgs-lock input map" {
    write_lock '"nixpkgs-lock":{"locked":{"owner":"pr0d1r2","repo":"nixpkgs-lock"},"inputs":{"set-and-setting":"setting"}},"setting":{"locked":{"owner":"pr0d1r2","repo":"set-and-setting"}},"root":{"inputs":{}}'
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"input set-and-setting"* ]]
}

@test "rejects an owner/repo cycle hidden by revision pins" {
    write_lock '"a1":{"locked":{"owner":"o","repo":"a"},"inputs":{"b":"b1"}},"b1":{"locked":{"owner":"o","repo":"b"},"inputs":{"a":"a2"}},"a2":{"locked":{"owner":"o","repo":"a"}},"root":{"inputs":{}}'
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"contains a cycle"* ]]
}

@test "rejects a collapsed cycle whose edge is encoded as a follows path" {
    write_lock '"a1":{"locked":{"owner":"o","repo":"a"},"inputs":{"b":["b"]}},"b1":{"locked":{"owner":"o","repo":"b"},"inputs":{"a":"a2"}},"a2":{"locked":{"owner":"o","repo":"a"}},"root":{"inputs":{"a":"a1","b":"b1"}}'
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"contains a cycle"* ]]
}
