#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for setting/lib/app-mk-setting.sh -- runnable installer
# for mkSetting. Materializes unified configs + content-aware lefthook.yml.

setup() {
    bats_require_minimum_version 1.5.0
    SETTING_SRC="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/app-mk-setting.sh"
    ASSEMBLE_SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/assemble-lefthook.sh"
    DETECT_SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/detect-fragments.sh"
    FRAGMENTS_DIR="$BATS_TEST_DIRNAME/../setting/integrations/lefthook"

    echo "markdownlint config" >"$SETTING_SRC/.markdownlint.yml"
    echo "yamllint config" >"$SETTING_SRC/.yamllint.yml"

    cd "$TARGET" || exit 1
    git init --quiet
    git config user.email "test@test.com"
    git config user.name "Test"

    export SETTING_SRC ASSEMBLE_SCRIPT DETECT_SCRIPT FRAGMENTS_DIR
}

teardown() {
    cd /
    rm -rf "$SETTING_SRC" "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: mkSetting"* ]]
    [[ "$output" == *"lefthook.yml"* ]]
}

@test "--list shows materialized config files including lefthook" {
    run bash "$SCRIPT" --list
    [ "$status" -eq 0 ]
    [[ "$output" == *".markdownlint.yml"* ]]
    [[ "$output" == *".yamllint.yml"* ]]
    [[ "$output" == *"lefthook.yml (content-aware:"* ]]
}

@test "--dry-run shows what would be materialized without writing" {
    run bash "$SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would materialize"* ]]
    [[ "$output" == *"Detected fragments:"* ]]
    [ ! -f "$TARGET/.markdownlint.yml" ]
    [ ! -f "$TARGET/lefthook.yml" ]
}

@test "default mode copies configs and lefthook into CWD" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced setting"* ]]
    [ -f "$TARGET/.markdownlint.yml" ]
    [ "$(cat "$TARGET/.markdownlint.yml")" = "markdownlint config" ]
    [ -f "$TARGET/.yamllint.yml" ]
    [ -f "$TARGET/lefthook.yml" ]
}

@test "lefthook.yml is properly assembled" {
    bash "$SCRIPT"
    grep -q '^---$' "$TARGET/lefthook.yml"
    grep -q 'remotes:' "$TARGET/lefthook.yml"
}

@test "overwrites existing files" {
    echo "old" >"$TARGET/.markdownlint.yml"
    echo "old lefthook" >"$TARGET/lefthook.yml"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/.markdownlint.yml")" = "markdownlint config" ]
    [ "$(cat "$TARGET/lefthook.yml")" != "old lefthook" ]
}

@test "idempotent -- re-running produces identical output" {
    bash "$SCRIPT"
    markdownlint_before="$(cat "$TARGET/.markdownlint.yml")"
    lefthook_before="$(cat "$TARGET/lefthook.yml")"
    bash "$SCRIPT"
    [ "$(cat "$TARGET/.markdownlint.yml")" = "$markdownlint_before" ]
    [ "$(cat "$TARGET/lefthook.yml")" = "$lefthook_before" ]
}

@test "content-aware: nix-only repo includes nix checks" {
    printf '' >"$TARGET/test.nix"
    git -C "$TARGET" add test.nix
    bash "$SCRIPT"
    # #97: nixfmt is a pinned check; #99: statix/deadnix/nix-no-embedded-shell
    # are pinned checks too -- no nix remotes remain.
    run ! grep -q 'nix-lefthook-statix' "$TARGET/lefthook.yml"
    run ! grep -q 'nix-lefthook-nixfmt' "$TARGET/lefthook.yml"
}

@test "content-aware: nix-only repo excludes shell checks" {
    printf '' >"$TARGET/test.nix"
    git -C "$TARGET" add test.nix
    bash "$SCRIPT"
    run ! grep -q 'nix-lefthook-shellcheck' "$TARGET/lefthook.yml"
}

@test "content-aware: adding shell files does not add pinned shell checks" {
    printf '' >"$TARGET/test.nix"
    git -C "$TARGET" add test.nix
    bash "$SCRIPT"
    run ! grep -q 'nix-lefthook-shellcheck' "$TARGET/lefthook.yml"

    # #100: shellcheck is now a pinned flake check, not a lefthook remote.
    printf '#!/bin/bash\n' >"$TARGET/test.sh"
    git -C "$TARGET" add test.sh
    bash "$SCRIPT"
    run ! grep -q 'nix-lefthook-shellcheck' "$TARGET/lefthook.yml"
}

@test "output message includes detected fragments" {
    printf '' >"$TARGET/test.nix"
    git -C "$TARGET" add test.nix
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"lefthook:"* ]]
    [[ "$output" == *"nix"* ]]
}
