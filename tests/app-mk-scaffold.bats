#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for setting/lib/app-mk-scaffold.sh -- runnable installer
# for mkScaffold. Scaffolds repo infrastructure files (flake.nix,
# lefthook.yml, .github/workflows/ci.yml) into CWD (skip-if-exists).
# lefthook.yml is now constructed from detected repo content.

setup() {
    bats_require_minimum_version 1.5.0
    SCAFFOLD_SRC="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/app-mk-scaffold.sh"
    ASSEMBLE_SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/assemble-lefthook.sh"
    DETECT_SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/detect-fragments.sh"
    FRAGMENTS_DIR="$BATS_TEST_DIRNAME/../setting/integrations/lefthook"

    echo "flake content" >"$SCAFFOLD_SRC/flake.nix"
    echo "bundled lefthook" >"$SCAFFOLD_SRC/lefthook.yml"
    mkdir -p "$SCAFFOLD_SRC/.github/workflows"
    echo "ci content" >"$SCAFFOLD_SRC/.github/workflows/ci.yml"

    cd "$TARGET" || exit 1
    git init --quiet
    git config user.email "test@test.com"
    git config user.name "Test"

    export SCAFFOLD_SRC ASSEMBLE_SCRIPT DETECT_SCRIPT FRAGMENTS_DIR
}

teardown() {
    cd /
    rm -rf "$SCAFFOLD_SRC" "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: mkScaffold"* ]]
    [[ "$output" == *"detected repo content"* ]]
    [[ "$output" == *"CACHIX_AUTH_TOKEN"* ]]
}

@test "--list shows scaffold files including content-aware lefthook" {
    run bash "$SCRIPT" --list
    [ "$status" -eq 0 ]
    [[ "$output" == *"flake.nix"* ]]
    [[ "$output" == *"lefthook.yml (content-aware:"* ]]
    [[ "$output" == *".github/workflows/ci.yml"* ]]
}

@test "--list does not show bundled lefthook.yml separately" {
    run bash "$SCRIPT" --list
    [ "$status" -eq 0 ]
    local count
    count="$(echo "$output" | grep -c 'lefthook.yml')"
    [ "$count" -eq 1 ]
}

@test "--dry-run shows what would be scaffolded without writing" {
    run bash "$SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would scaffold"* ]]
    [[ "$output" == *"Detected fragments:"* ]]
    [ ! -f "$TARGET/flake.nix" ]
    [ ! -f "$TARGET/lefthook.yml" ]
}

@test "--dry-run marks existing files as skip" {
    echo "custom" >"$TARGET/flake.nix"
    run bash "$SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"flake.nix (skip -- exists)"* ]]
}

@test "--dry-run marks existing lefthook.yml as skip" {
    echo "custom" >"$TARGET/lefthook.yml"
    run bash "$SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"lefthook.yml (skip -- exists)"* ]]
}

@test "default mode scaffolds missing files" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"synced scaffold"* ]]
    [ -f "$TARGET/flake.nix" ]
    [ "$(cat "$TARGET/flake.nix")" = "flake content" ]
    [ -f "$TARGET/lefthook.yml" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
    [ "$(cat "$TARGET/.github/workflows/ci.yml")" = "ci content" ]
}

@test "lefthook.yml is assembled from fragments, not bundled copy" {
    bash "$SCRIPT"
    [ "$(cat "$TARGET/lefthook.yml")" != "bundled lefthook" ]
    grep -q '^---$' "$TARGET/lefthook.yml"
    grep -q 'remotes:' "$TARGET/lefthook.yml"
}

@test "skips files that already exist" {
    echo "custom flake" >"$TARGET/flake.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/flake.nix")" = "custom flake" ]
    [ -f "$TARGET/lefthook.yml" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
}

@test "skips lefthook.yml when it already exists" {
    echo "custom lefthook" >"$TARGET/lefthook.yml"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/lefthook.yml")" = "custom lefthook" ]
}

@test "creates parent directories for nested files" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -d "$TARGET/.github/workflows" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
}

@test "idempotent -- re-running changes nothing" {
    bash "$SCRIPT"
    flake_before="$(cat "$TARGET/flake.nix")"
    lefthook_before="$(cat "$TARGET/lefthook.yml")"
    ci_before="$(cat "$TARGET/.github/workflows/ci.yml")"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/flake.nix")" = "$flake_before" ]
    [ "$(cat "$TARGET/lefthook.yml")" = "$lefthook_before" ]
    [ "$(cat "$TARGET/.github/workflows/ci.yml")" = "$ci_before" ]
}

@test "content-aware: nix-only repo gets nix checks" {
    printf '' >"$TARGET/test.nix"
    git -C "$TARGET" add test.nix
    bash "$SCRIPT"
    grep -q 'nix-lefthook-nixfmt' "$TARGET/lefthook.yml"
    grep -q 'nix-lefthook-trailing-whitespace' "$TARGET/lefthook.yml"
}

@test "content-aware: nix-only repo excludes shell checks" {
    printf '' >"$TARGET/test.nix"
    git -C "$TARGET" add test.nix
    bash "$SCRIPT"
    run ! grep -q 'nix-lefthook-shellcheck' "$TARGET/lefthook.yml"
}

@test "content-aware: empty repo gets all fragments" {
    bash "$SCRIPT"
    grep -q 'nix-lefthook-nixfmt' "$TARGET/lefthook.yml"
    grep -q 'nix-lefthook-shellcheck' "$TARGET/lefthook.yml"
    grep -q 'nix-lefthook-markdownlint' "$TARGET/lefthook.yml"
    grep -q 'nix-lefthook-yamllint' "$TARGET/lefthook.yml"
}
