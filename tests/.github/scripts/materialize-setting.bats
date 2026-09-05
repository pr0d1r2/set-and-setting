#!/usr/bin/env bats

# .github/scripts/materialize-setting.sh — the darwin job has no dev shell
# entry before its checks, so the configs the gate reads are built and synced
# explicitly (T81).

setup() {
    load "../../github-scripts-setup"
    github_scripts_setup
}

teardown() { rm -rf "$TMP"; }

@test "builds the setting and syncs it into the checkout" {
    run bash "$DIR/materialize-setting.sh"
    [ "$status" -eq 0 ]
    run cat "$LOG"
    [[ "$output" == *"nix build .#setting --print-out-paths --no-link"* ]]
    [[ "$output" == *"sync ."* ]]
}
