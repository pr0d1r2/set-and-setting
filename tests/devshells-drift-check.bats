#!/usr/bin/env bats

# Unit tests for lib/devshells-drift-check.sh -- CI skip-lefthook guard.
# Contract: when CHECK_CI_SKIP_LEFTHOOK is set, scan .github/workflows/
# for skip-lefthook: true; exit 1 if found, 0 otherwise.

setup() {
    ACTUAL="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/devshells-drift-check.sh"
    export ACTUAL
    export CHECK_CI_SKIP_LEFTHOOK="1"
}

teardown() {
    rm -rf "$ACTUAL"
}

@test "exit 0 when CHECK_CI_SKIP_LEFTHOOK is empty (disabled)" {
    CHECK_CI_SKIP_LEFTHOOK="" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "exit 0 when no .github/workflows directory" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "exit 0 when CI workflow has no skip-lefthook" {
    mkdir -p "$ACTUAL/.github/workflows"
    printf '%s\n' \
        'jobs:' \
        '    build:' \
        '        steps:' \
        '            - uses: nix-lefthook-ci-action' \
        '              with:' \
        '                  devshell: "default"' \
        '                  skip-build: "true"' \
        > "$ACTUAL/.github/workflows/ci.yml"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"no CI skip-lefthook"* ]]
}

@test "exit 1 when CI workflow has skip-lefthook: true (quoted)" {
    mkdir -p "$ACTUAL/.github/workflows"
    printf '%s\n' \
        'jobs:' \
        '    build:' \
        '        steps:' \
        '            - uses: nix-lefthook-ci-action' \
        '              with:' \
        '                  skip-lefthook: "true"' \
        > "$ACTUAL/.github/workflows/ci.yml"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"skip-lefthook: true"* ]]
    [[ "$output" == *"DEVSHELL DRIFT"* ]]
}

@test "exit 1 when CI workflow has skip-lefthook: true (unquoted)" {
    mkdir -p "$ACTUAL/.github/workflows"
    printf '%s\n' \
        'jobs:' \
        '    build:' \
        '        steps:' \
        '            - uses: nix-lefthook-ci-action' \
        '              with:' \
        '                  skip-lefthook: true' \
        > "$ACTUAL/.github/workflows/ci.yml"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"skip-lefthook: true"* ]]
}

@test "exit 0 when skip-lefthook is false" {
    mkdir -p "$ACTUAL/.github/workflows"
    printf '%s\n' \
        'jobs:' \
        '    build:' \
        '        steps:' \
        '            - uses: nix-lefthook-ci-action' \
        '              with:' \
        '                  skip-lefthook: "false"' \
        > "$ACTUAL/.github/workflows/ci.yml"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "scans multiple workflow files" {
    mkdir -p "$ACTUAL/.github/workflows"
    printf '%s\n' \
        'jobs:' \
        '    build:' \
        '        steps:' \
        '            - uses: nix-lefthook-ci-action' \
        '              with:' \
        '                  devshell: "default"' \
        > "$ACTUAL/.github/workflows/ci.yml"
    printf '%s\n' \
        'jobs:' \
        '    deploy:' \
        '        steps:' \
        '            - uses: nix-lefthook-ci-action' \
        '              with:' \
        '                  skip-lefthook: "true"' \
        > "$ACTUAL/.github/workflows/deploy.yml"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"deploy.yml"* ]]
}

@test "handles .yaml extension" {
    mkdir -p "$ACTUAL/.github/workflows"
    printf '%s\n' \
        'jobs:' \
        '    build:' \
        '        steps:' \
        '            - uses: nix-lefthook-ci-action' \
        '              with:' \
        '                  skip-lefthook: "true"' \
        > "$ACTUAL/.github/workflows/ci.yaml"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ci.yaml"* ]]
}
