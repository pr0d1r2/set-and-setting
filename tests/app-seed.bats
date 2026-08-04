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
    printf '%s\n' '# __REPO__' 'https://github.com/__OWNER__/__REPO__' '<!-- Fill in __OWNER__ and __REPO__ in the badge URLs when the repository coordinates are known. -->' >"$SEED_SRC/README.md"
    echo 'Copyright (c) __YEAR__ __HOLDER__' >"$SEED_SRC/LICENSE"

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
    [[ "$output" == *"canonical repository tree"* ]]
}

@test "--list shows seed files" {
    run bash "$SCRIPT" --list
    [ "$status" -eq 0 ]
    [[ "$output" == *"flake.nix"* ]]
    [[ "$output" == *".gitignore"* ]]
    [[ "$output" == *".github/workflows/ci.yml"* ]]
    [[ "$output" == *"README.md"* ]]
    [[ "$output" == *"LICENSE"* ]]
    [[ "$output" != *"auto-update"* ]]
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
    [ ! -f "$TARGET/.github/workflows/auto-update.yml" ]
    [ "$(head -1 "$TARGET/README.md")" = "# ${TARGET##*/}" ]
    grep -q '__OWNER__/__REPO__' "$TARGET/README.md"
    grep -q 'Fill in __OWNER__ and __REPO__' "$TARGET/README.md"
    grep -q "Copyright (c) $(date -u +%Y) __HOLDER__" "$TARGET/LICENSE"
}

@test "explicit trip coordinates substitute README and LICENSE placeholders" {
    run bash "$SCRIPT" --owner octocat --repo hello-world --holder "The Octocat" --year 2025
    [ "$status" -eq 0 ]
    [ "$(head -1 "$TARGET/README.md")" = "# hello-world" ]
    grep -q 'github.com/octocat/hello-world' "$TARGET/README.md"
    ! grep -q '__OWNER__\|__REPO__\|Fill in' "$TARGET/README.md"
    grep -q 'Copyright (c) 2025 The Octocat' "$TARGET/LICENSE"
    ! grep -q '__YEAR__\|__HOLDER__' "$TARGET/LICENSE"
}

@test "canonical mode substitutes SPEC description and installs hooks" {
    printf '%s\n' '# SPEC -- __REPO__' '__DESCRIPTION__' >"$SEED_SRC/SPEC.md"
    mkdir -p "$TARGET/bin"
    printf '%s\n' '#!/usr/bin/env bash' 'echo installed > .hook-installed' >"$TARGET/bin/lefthook"
    chmod +x "$TARGET/bin/lefthook"
    git init --quiet
    run env PATH="$TARGET/bin:$PATH" CANON_APP_NAME=mkCanon CANON_APP_LABEL=canon \
        CANON_INSTALL_HOOKS=1 bash "$SCRIPT" --repo project \
        --description "A useful Nix/Linux project."
    [ "$status" -eq 0 ]
    [[ "$output" == *"canon complete"* ]]
    grep -q '^# SPEC -- project$' SPEC.md
    grep -q '^A useful Nix/Linux project\.$' SPEC.md
    [ -f .hook-installed ]
}

@test "trip environment coordinates are accepted" {
    TRIP_OWNER=octocat TRIP_REPO=env-repo TRIP_YEAR=2024 run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q 'github.com/octocat/env-repo' "$TARGET/README.md"
    grep -q 'Copyright (c) 2024 octocat' "$TARGET/LICENSE"
}

@test "origin coordinates are inferred when explicit coordinates are absent" {
    git init -q
    git remote add origin git@github.com:octocat/remote-repo.git
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q 'github.com/octocat/remote-repo' "$TARGET/README.md"
    grep -q 'Copyright (c) .* octocat' "$TARGET/LICENSE"
}

@test "refuses to seed set-and-setting without emitting files (#339)" {
    run bash "$SCRIPT" --repo set-and-setting
    [ "$status" -eq 1 ]
    [[ "$output" == *"refusing to seed leaf template into foundation repository: set-and-setting"* ]]
    [ ! -e "$TARGET/flake.nix" ]
}

@test "refuses to seed nix-lefthook without emitting files (#339)" {
    run bash "$SCRIPT" --repo nix-lefthook
    [ "$status" -eq 1 ]
    [[ "$output" == *"refusing to seed leaf template into foundation repository: nix-lefthook"* ]]
    [ ! -e "$TARGET/flake.nix" ]
}

@test "refuses to seed nixpkgs-lock without emitting files (#339)" {
    run bash "$SCRIPT" --repo nixpkgs-lock
    [ "$status" -eq 1 ]
    [[ "$output" == *"refusing to seed leaf template into foundation repository: nixpkgs-lock"* ]]
    [ ! -e "$TARGET/flake.nix" ]
}

@test "skips files that already exist" {
    echo "custom flake" >"$TARGET/flake.nix"
    echo "custom readme" >"$TARGET/README.md"
    echo "custom license" >"$TARGET/LICENSE"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$TARGET/flake.nix")" = "custom flake" ]
    [ "$(cat "$TARGET/README.md")" = "custom readme" ]
    [ "$(cat "$TARGET/LICENSE")" = "custom license" ]
    [ -f "$TARGET/.gitignore" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
}

@test "creates parent directories for nested files" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -d "$TARGET/.github/workflows" ]
    [ -f "$TARGET/.github/workflows/ci.yml" ]
    [ ! -f "$TARGET/.github/workflows/auto-update.yml" ]
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
