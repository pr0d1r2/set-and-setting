#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for setting/lib/detect-fragments.sh -- detects which lefthook
# fragments apply to a repo based on tracked file types.

setup() {
    bats_require_minimum_version 1.5.0
    REPO="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/detect-fragments.sh"
    cd "$REPO" || exit 1
    git init --quiet
    git config user.email "test@test.com"
    git config user.name "Test"
}

teardown() {
    cd /
    rm -rf "$REPO"
}

@test "empty repo defaults to all fragments" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base nix shell ascii markdown yaml" ]
}

@test "nix-only repo detects nix" {
    printf '' >test.nix
    git add test.nix
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base nix ascii" ]
}

@test "shell-only repo detects shell" {
    printf '#!/bin/bash\n' >test.sh
    git add test.sh
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base shell ascii" ]
}

@test ".bash extension detected as shell" {
    printf '#!/bin/bash\n' >test.bash
    git add test.bash
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base shell ascii" ]
}

@test "markdown-only repo detects markdown" {
    printf '# Title\n' >README.md
    git add README.md
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ascii markdown" ]
}

@test "yaml-only repo detects yaml" {
    printf 'key: value\n' >config.yml
    git add config.yml
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ascii yaml" ]
}

@test ".yaml extension detected" {
    printf 'key: value\n' >config.yaml
    git add config.yaml
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ascii yaml" ]
}

@test "mixed nix+markdown repo" {
    printf '' >test.nix
    printf '# Title\n' >README.md
    git add test.nix README.md
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base nix ascii markdown" ]
}

@test "full repo includes all fragments" {
    printf '' >test.nix
    printf '#!/bin/bash\n' >test.sh
    printf '# Title\n' >README.md
    printf 'key: value\n' >config.yml
    git add test.nix test.sh README.md config.yml
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base nix shell ascii markdown yaml" ]
}

@test "fragment order is deterministic" {
    printf '' >test.nix
    printf 'key: value\n' >config.yml
    printf '# Title\n' >README.md
    printf '#!/bin/bash\n' >test.sh
    git add config.yml README.md test.sh test.nix
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base nix shell ascii markdown yaml" ]
}

@test "base and ascii always present" {
    printf 'data\n' >plain.txt
    git add plain.txt
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ascii" ]
}

@test "nested files detected" {
    mkdir -p src/lib
    printf '' >src/lib/build.nix
    git add src/lib/build.nix
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base nix ascii" ]
}
