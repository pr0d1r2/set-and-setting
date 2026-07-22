#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for setting/lib/app-mk-setting-init.sh -- runnable installer
# for mkSetting-init. Seeds repo-specific starter files (skip-if-exists).

setup() {
    bats_require_minimum_version 1.5.0
    SEED_SRC="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/app-mk-setting-init.sh"
    echo "editorconfig" >"$SEED_SRC/.editorconfig"
    echo "gitattributes" >"$SEED_SRC/.gitattributes"
    echo "gitignore" >"$SEED_SRC/.gitignore"
    mkdir -p "$SEED_SRC/config/lefthook"
    echo "limits" >"$SEED_SRC/config/lefthook/file_size_limits.yml"
    printf '%s\n' '# __REPO__' 'https://github.com/__OWNER__/__REPO__' >"$SEED_SRC/README.md"
    printf '%s\n' 'Copyright (c) __YEAR__ __HOLDER__' >"$SEED_SRC/LICENSE"
    export SEED_SRC
}

teardown() {
    rm -rf "$SEED_SRC" "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: mkSetting-init"* ]]
}

@test "--list shows seed files" {
    run bash "$SCRIPT" --list
    [ "$status" -eq 0 ]
    [[ "$output" == *".editorconfig"* ]]
    [[ "$output" == *".gitattributes"* ]]
}

@test "--dry-run shows what would be scaffolded without writing" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would scaffold"* ]]
    [ ! -f "$TARGET/.editorconfig" ]
}

@test "--dry-run marks existing files as skip" {
    echo "custom" >"$TARGET/.editorconfig"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *".editorconfig (skip -- exists)"* ]]
}

@test "default mode scaffolds missing files" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced setting-init"* ]]
    [ -f "$TARGET/.editorconfig" ]
    [ "$(cat "$TARGET/.editorconfig")" = "editorconfig" ]
    [ -f "$TARGET/.gitattributes" ]
    [ -f "$TARGET/.gitignore" ]
    [ -f "$TARGET/config/lefthook/file_size_limits.yml" ]
    [ "$(head -1 "$TARGET/README.md")" = "# ${TARGET##*/}" ]
    grep -q '__OWNER__/__REPO__' "$TARGET/README.md"
    grep -q '__YEAR__ __HOLDER__' "$TARGET/LICENSE"
}

@test "skips existing README and LICENSE" {
    echo "custom readme" >"$TARGET/README.md"
    echo "custom license" >"$TARGET/LICENSE"
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/README.md")" = "custom readme" ]
    [ "$(cat "$TARGET/LICENSE")" = "custom license" ]
}

@test "skips files that already exist" {
    echo "custom" >"$TARGET/.editorconfig"
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/.editorconfig")" = "custom" ]
    [ -f "$TARGET/.gitattributes" ]
}
