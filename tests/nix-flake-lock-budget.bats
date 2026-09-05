#!/usr/bin/env bats

setup() {
    ROOT=$(mktemp -d)
    SCRIPT="$BATS_TEST_DIRNAME/../lib/nix-flake-lock-budget.sh"
    mkdir -p "$ROOT/config/lefthook"
    cp "$BATS_TEST_DIRNAME/../config/lefthook/flake_lock_budget.yml" "$ROOT/config/lefthook/"
}

teardown() { rm -rf "$ROOT"; }

write_lock() {
    printf '{"nodes":{%s},"root":"root","version":7}\n' "$1" >"$ROOT/flake.lock"
}

@test "lock growth within ratchet passes" {
    write_lock '"root":{"locked":{"owner":"o","repo":"a"}},"new":{"locked":{"owner":"o","repo":"b"}}'
    FLAKE_LOCK="$ROOT/flake.lock" FLAKE_LOCK_BASELINE="$ROOT/config/lefthook/flake_lock_budget.yml" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "duplicated nodes fail the duplication ratchet" {
    sed -i 's/baseline_duplication_ratio: 1000/baseline_duplication_ratio: 1000/' "$ROOT/config/lefthook/flake_lock_budget.yml"
    write_lock '"a":{"locked":{"owner":"o","repo":"same"}},"b":{"locked":{"owner":"o","repo":"same"}},"c":{"locked":{"owner":"o","repo":"same"}},"d":{"locked":{"owner":"o","repo":"same"}},"e":{"locked":{"owner":"o","repo":"same"}},"f":{"locked":{"owner":"o","repo":"same"}},"g":{"locked":{"owner":"o","repo":"same"}},"h":{"locked":{"owner":"o","repo":"same"}},"i":{"locked":{"owner":"o","repo":"same"}},"j":{"locked":{"owner":"o","repo":"same"}},"k":{"locked":{"owner":"o","repo":"same"}},"l":{"locked":{"owner":"o","repo":"same"}},"m":{"locked":{"owner":"o","repo":"same"}},"n":{"locked":{"owner":"o","repo":"same"}},"p":{"locked":{"owner":"o","repo":"same"}},"q":{"locked":{"owner":"o","repo":"same"}}'
    FLAKE_LOCK="$ROOT/flake.lock" FLAKE_LOCK_BASELINE="$ROOT/config/lefthook/flake_lock_budget.yml" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"duplication_ratio"* ]]
}
