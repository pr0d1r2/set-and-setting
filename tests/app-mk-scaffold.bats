#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for setting/lib/app-mk-scaffold.sh -- runnable installer
# for mkScaffold. Scaffolds repo infrastructure files (flake.nix,
# lefthook.yml, .github/workflows/ci.yml) into CWD (skip-if-exists).

setup() {
    bats_require_minimum_version 1.5.0
    SCAFFOLD_SRC="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/app-mk-scaffold.sh"
    echo "flake content" >"$SCAFFOLD_SRC/flake.nix"
    echo "lefthook content" >"$SCAFFOLD_SRC/lefthook.yml"
    mkdir -p "$SCAFFOLD_SRC/.github/workflows"
    echo "ci content" >"$SCAFFOLD_SRC/.github/workflows/ci.yml"
    export SCAFFOLD_SRC
}

teardown() {
    rm -rf "$SCAFFOLD_SRC" "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: mkScaffold"* ]]
    [[ "$output" == *"flake.nix"* ]]
    [[ "$output" == *"lefthook.yml"* ]]
    [[ "$output" == *"CACHIX_AUTH_TOKEN"* ]]
}

@test "--list shows scaffold files" {
    run bash "$SCRIPT" --list
    [ "$status" -eq 0 ]
    [[ "$output" == *"flake.nix"* ]]
    [[ "$output" == *"lefthook.yml"* ]]
    [[ "$output" == *".github/workflows/ci.yml"* ]]
}

@test "--dry-run shows what would be scaffolded without writing" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would scaffold"* ]]
    [ ! -f "$TARGET/flake.nix" ]
    [ ! -f "$TARGET/lefthook.yml" ]
}

@test "--dry-run marks existing files as skip" {
    echo "custom" >"$TARGET/flake.nix"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"flake.nix (skip -- exists)"* ]]
}

@test "default mode scaffolds missing files" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced scaffold"* ]]
    [ -f "$TARGET/flake.nix" ]
    [ "$(cat "$TARGET/flake.nix")" = "flake content" ]
    [ -f "$TARGET/lefthook.yml" ]
    [ "$(cat "$TARGET/lefthook.yml")" = "lefthook content" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
    [ "$(cat "$TARGET/.github/workflows/ci.yml")" = "ci content" ]
}

@test "skips files that already exist" {
    echo "custom flake" >"$TARGET/flake.nix"
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/flake.nix")" = "custom flake" ]
    [ -f "$TARGET/lefthook.yml" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
}

@test "creates parent directories for nested files" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ -d "$TARGET/.github/workflows" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
}

@test "idempotent -- re-running changes nothing" {
    bash -c "cd '$TARGET' && bash '$SCRIPT'"
    flake_before="$(cat "$TARGET/flake.nix")"
    lefthook_before="$(cat "$TARGET/lefthook.yml")"
    ci_before="$(cat "$TARGET/.github/workflows/ci.yml")"
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/flake.nix")" = "$flake_before" ]
    [ "$(cat "$TARGET/lefthook.yml")" = "$lefthook_before" ]
    [ "$(cat "$TARGET/.github/workflows/ci.yml")" = "$ci_before" ]
}
