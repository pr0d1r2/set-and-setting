#!/usr/bin/env bats

# .github/scripts/cache-build.sh — the cache-push jobs build the delivery
# paths (which is what populates the cache) and check them, so a pushed closure
# is never one the gate would reject (T81).

setup() {
    load "../../github-scripts-setup"
    github_scripts_setup
}

teardown() { rm -rf "$TMP"; }

@test "builds the delivery paths AND checks them" {
    run bash "$DIR/cache-build.sh"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [[ "$output" == *"nix build .#set .#setting --no-link"* ]]
    [[ "$output" == *"nix flake check --print-build-logs"* ]]
}
