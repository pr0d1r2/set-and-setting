#!/usr/bin/env bats

# .github/scripts/flake-check.sh — the pinned flake check both platform jobs
# run. It was four identical lines inside each job's `run:` block, where no
# linter could see it (T81).

setup() {
    load "../../github-scripts-setup"
    github_scripts_setup
}

teardown() { rm -rf "$TMP"; }

@test "the workflow's timeout input reaches the check" {
    FLAKE_CHECK_TIMEOUT=42 run bash "$DIR/flake-check.sh"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [[ "$output" == *"flake check --print-build-logs --timeout 42"* ]]
}

@test "a missing input is a default, not an empty timeout" {
    run bash "$DIR/flake-check.sh"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [[ "$output" == *"--timeout 600"* ]]
}
