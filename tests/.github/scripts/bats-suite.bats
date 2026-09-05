#!/usr/bin/env bats

# .github/scripts/bats-suite.sh — parse, then run every tracked Bats file
# SEQUENTIALLY, then the TDD-order gate. Sequential is the whole point
# (B16/B18/B70): the files share git and test state.

setup() {
    load "../../github-scripts-setup"
    github_scripts_setup
}

teardown() { rm -rf "$TMP"; }

@test "runs the suite sequentially — no --jobs reaches the runner" {
    cd "$TMP"
    git init -q .
    git config user.email t@t
    git config user.name t
    : >"a.bats"
    git add a.bats
    run bash "$DIR/bats-suite.sh"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [[ "$output" == *"lefthook-bats-parse a.bats"* ]]
    [[ "$output" != *"--jobs"* ]]
}

@test "a repository with no Bats files still runs the TDD-order gate" {
    cd "$TMP"
    git init -q .
    git config user.email t@t
    git config user.name t
    run bash "$DIR/bats-suite.sh"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [[ "$output" != *"bats-parse"* ]]
    [[ "$output" == *"lefthook-tdd-order-bats"* ]]
}
