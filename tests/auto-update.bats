#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for lib/auto-update.sh -- auto-update mechanism (T8/C7).

setup() {
    bats_require_minimum_version 1.5.0
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/auto-update.sh"

    # Build a minimal git repo with a flake.lock that references
    # set-and-setting so the script can parse it.
    git -C "$TARGET" init --initial-branch=main
    git -C "$TARGET" config user.email "test@test.com"
    git -C "$TARGET" config user.name "test"
    printf '{"nodes":{"set-and-setting":{"locked":{"rev":"abc123"}}}}\n' \
        >"$TARGET/flake.lock"
    git -C "$TARGET" add flake.lock
    git -C "$TARGET" commit -m "init"
}

teardown() {
    chmod -R u+w "$TARGET" 2>/dev/null || true
    rm -rf "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: auto-update"* ]]
    [[ "$output" == *"--dry-run"* ]]
    [[ "$output" == *"--no-commit"* ]]
    [[ "$output" == *"--input NAME"* ]]
}

@test "unknown option fails with guidance" {
    run bash "$SCRIPT" --bogus
    [ "$status" -eq 1 ]
    [[ "$output" == *"error: unknown option"* ]]
}

@test "--input without name fails" {
    run bash "$SCRIPT" --input
    [ "$status" -eq 1 ]
    [[ "$output" == *"--input requires a name"* ]]
}

@test "fails outside a git repository" {
    nodir="$(mktemp -d)"
    run bash -c "cd '$nodir' && bash '$SCRIPT'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not a git repository"* ]]
    rm -rf "$nodir"
}

@test "fails without flake.lock" {
    nolock="$(mktemp -d)"
    git -C "$nolock" init --initial-branch=main
    run bash -c "cd '$nolock' && bash '$SCRIPT'"
    [ "$status" -eq 1 ]
    [[ "$output" == *"no flake.lock found"* ]]
    rm -rf "$nolock"
}

@test "fails when input not in flake.lock" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --input bogus-input"
    [ "$status" -eq 1 ]
    [[ "$output" == *"flake input 'bogus-input' not found"* ]]
}

@test "--dry-run shows what would happen without writing" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would update flake input: set-and-setting"* ]]
    [[ "$output" == *"Would sync set and setting"* ]]
    [[ "$output" == *"Would commit flake.lock"* ]]
}

@test "--dry-run --no-commit omits commit line" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run --no-commit"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would update flake input: set-and-setting"* ]]
    [[ "$output" != *"Would commit"* ]]
}

@test "--dry-run --input custom-name uses custom input" {
    printf '{"nodes":{"custom-name":{"locked":{"rev":"abc"}}}}\n' \
        >"$TARGET/flake.lock"
    git -C "$TARGET" add flake.lock
    git -C "$TARGET" commit -m "custom"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run --input custom-name"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would update flake input: custom-name"* ]]
}
