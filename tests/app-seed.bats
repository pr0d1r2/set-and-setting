#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for lib/app-seed.sh -- leaf consumer seed emitter (#95).

setup() {
    bats_require_minimum_version 1.5.0
    SEED_SRC="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/app-seed.sh"

    echo "leaf flake content" >"$SEED_SRC/flake.nix"
    echo "leaf gitignore" >"$SEED_SRC/.gitignore"
    mkdir -p "$SEED_SRC/.github/workflows"
    printf '%s\n' "jobs:" "  guardrails:" "    uses: pr0d1r2/set-and-setting/.github/workflows/guardrails.yml@main" >"$SEED_SRC/.github/workflows/ci.yml"
    echo "auto-update" >"$SEED_SRC/.github/workflows/auto-update.yml"

    cd "$TARGET" || exit 1
    export SEED_SRC
}

teardown() {
    cd /
    rm -rf "$SEED_SRC" "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: seed"* ]]
    [[ "$output" == *"committed minimum"* ]]
    [[ "$output" == *"flake.nix"* ]]
}

@test "--list shows seed files" {
    run bash "$SCRIPT" --list
    [ "$status" -eq 0 ]
    [[ "$output" == *"flake.nix"* ]]
    [[ "$output" == *".gitignore"* ]]
    [[ "$output" == *".github/workflows/ci.yml"* ]]
    [[ "$output" == *".github/workflows/auto-update.yml"* ]]
}

@test "--dry-run shows what would be seeded without writing" {
    run bash "$SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would seed"* ]]
    [ ! -f "$TARGET/flake.nix" ]
    [ ! -f "$TARGET/.gitignore" ]
}

@test "--dry-run marks existing files as skip" {
    echo "custom" >"$TARGET/flake.nix"
    run bash "$SCRIPT" --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"flake.nix (skip -- exists)"* ]]
}

@test "default mode seeds missing files" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"seed complete"* ]]
    [ -f "$TARGET/flake.nix" ]
    [ "$(cat "$TARGET/flake.nix")" = "leaf flake content" ]
    [ -f "$TARGET/.gitignore" ]
    [ "$(cat "$TARGET/.gitignore")" = "leaf gitignore" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
    grep -q "guardrails" "$TARGET/.github/workflows/ci.yml"
    [ -f "$TARGET/.github/workflows/auto-update.yml" ]
}

@test "skips files that already exist" {
    echo "custom flake" >"$TARGET/flake.nix"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/flake.nix")" = "custom flake" ]
    [ -f "$TARGET/.gitignore" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
}

@test "creates parent directories for nested files" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -d "$TARGET/.github/workflows" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
    [ -f "$TARGET/.github/workflows/auto-update.yml" ]
}

@test "idempotent -- re-running changes nothing" {
    bash "$SCRIPT"
    flake_before="$(cat "$TARGET/flake.nix")"
    gitignore_before="$(cat "$TARGET/.gitignore")"
    ci_before="$(cat "$TARGET/.github/workflows/ci.yml")"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/flake.nix")" = "$flake_before" ]
    [ "$(cat "$TARGET/.gitignore")" = "$gitignore_before" ]
    [ "$(cat "$TARGET/.github/workflows/ci.yml")" = "$ci_before" ]
}

@test "leaf CI uses reusable guardrails workflow" {
    bash "$SCRIPT"
    grep -q "guardrails" "$TARGET/.github/workflows/ci.yml" || {
        echo "FAIL: leaf CI should reference guardrails workflow"
        return 1
    }
}
