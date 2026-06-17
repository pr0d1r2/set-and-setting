#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for setting/lib/app-mk-setting.sh -- runnable installer
# for mkSetting. Materializes unified configs into CWD.

setup() {
    bats_require_minimum_version 1.5.0
    SETTING_SRC="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/app-mk-setting.sh"
    echo "markdownlint config" >"$SETTING_SRC/.markdownlint.yml"
    echo "yamllint config" >"$SETTING_SRC/.yamllint.yml"
    export SETTING_SRC
}

teardown() {
    rm -rf "$SETTING_SRC" "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: mkSetting"* ]]
}

@test "--list shows materialized config files" {
    run bash "$SCRIPT" --list
    [ "$status" -eq 0 ]
    [[ "$output" == *".markdownlint.yml"* ]]
    [[ "$output" == *".yamllint.yml"* ]]
}

@test "--dry-run shows what would be materialized without writing" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would materialize"* ]]
    [ ! -f "$TARGET/.markdownlint.yml" ]
}

@test "default mode copies configs into CWD" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced setting"* ]]
    [ -f "$TARGET/.markdownlint.yml" ]
    [ "$(cat "$TARGET/.markdownlint.yml")" = "markdownlint config" ]
    [ -f "$TARGET/.yamllint.yml" ]
}

@test "overwrites existing files" {
    echo "old" >"$TARGET/.markdownlint.yml"
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/.markdownlint.yml")" = "markdownlint config" ]
}
