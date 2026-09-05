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
    # Assert the pieces, not their order: --keep-going now sits between them,
    # and an order-pinned assertion breaks on every future flag.
    [[ "$output" == *"flake check"* ]]
    [[ "$output" == *"--timeout 42"* ]]
}

@test "a missing input is a default, not an empty timeout" {
    run bash "$DIR/flake-check.sh"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [[ "$output" == *"--timeout 600"* ]]
}

@test "reports EVERY failing check in one run, not just the first (#489)" {
    # The tending loop's unit of cost is the round trip: without --keep-going,
    # five defects cost five CI rounds.
    FLAKE_CHECK_TIMEOUT=1 run bash "$DIR/flake-check.sh"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [[ "$output" == *"--keep-going"* ]]
}

@test "keeps the build logs, so a failure names itself" {
    run bash "$DIR/flake-check.sh"
    run cat "$LOG"
    [[ "$output" == *"--print-build-logs"* ]]
}
