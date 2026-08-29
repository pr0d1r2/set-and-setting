#!/usr/bin/env bats

setup() {
    TARGET="$BATS_TEST_TMPDIR/fixture"
    mkdir -p "$TARGET/config/lefthook"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/flake-lock-budget.sh"
    printf '%s\n' 'max_bytes: 10000' 'max_nodes: 10' 'max_ratio: 4' >"$TARGET/config/lefthook/flake_lock_budget.yml"
    printf '%s\n' '{"bytes": 1,"nodes": 1,"ratio": 1}' >"$TARGET/config/lefthook/flake_lock_baseline.json"
}

@test "growth in a unique lock passes" {
    printf '%s\n' '{"nodes":{"root":{"inputs":{}},"a":{"locked":{"type":"github","owner":"o","repo":"a"}}},"root":"root","version":7}' >"$TARGET/flake.lock"
    pushd "$TARGET" >/dev/null
    run bash "$SCRIPT" flake.lock
    popd >/dev/null
    [ "$status" -eq 0 ]
}

@test "duplicating a locked identity fails the ratchet" {
    printf '%s\n' '{"nodes":{"root":{"inputs":{}},"a":{"locked":{"type":"github","owner":"o","repo":"a"}},"b":{"locked":{"type":"github","owner":"o","repo":"a"}}},"root":"root","version":7}' >"$TARGET/flake.lock"
    pushd "$TARGET" >/dev/null
    run bash "$SCRIPT" flake.lock
    popd >/dev/null
    [ "$status" -ne 0 ]
    [[ "$output" == *"ratchet violation"* ]]
}

@test "nodes without a lock identity are not treated as duplicates" {
    printf '%s\n' '{"nodes":{"root":{"inputs":{}},"a":{"inputs":{}},"b":{"inputs":{}}},"root":"root","version":7}' >"$TARGET/flake.lock"
    pushd "$TARGET" >/dev/null
    run bash "$SCRIPT" flake.lock
    popd >/dev/null
    [ "$status" -eq 0 ]
}
