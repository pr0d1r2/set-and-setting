#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for lib/confirm.sh -- post-materialization acceptance suite (#94).

setup() {
    bats_require_minimum_version 1.5.0
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/confirm.sh"
    ASSEMBLE_SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/assemble-lefthook.sh"
    DETECT_SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/detect-fragments.sh"
    FRAGMENTS_DIR="$BATS_TEST_DIRNAME/../setting/integrations/lefthook"

    cd "$TARGET"
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"

    SETTING_DIR="$(mktemp -d)"
    printf '%s\n' "---" "extends: default" > "$SETTING_DIR/.markdownlint.yml"
    printf '%s\n' "---" "extends: default" > "$SETTING_DIR/.yamllint.yml"

    export FRAGMENTS_DIR ASSEMBLE_SCRIPT DETECT_SCRIPT
    export SETTING_SRC="$SETTING_DIR"
    export CONFIRM_REV="abc1234"
}

teardown() {
    rm -rf "$TARGET" "$SETTING_DIR"
}

materialize_basic() {
    touch flake.lock
    printf '%s\n' ".markdownlint.yml" ".yamllint.yml" "lefthook.yml" >.gitignore
    cp "$SETTING_SRC/.markdownlint.yml" .markdownlint.yml
    cp "$SETTING_SRC/.yamllint.yml" .yamllint.yml
    git add .
    local detected
    detected="$(bash "$DETECT_SCRIPT")"
    local assemble_out
    assemble_out="$(mktemp -d)"
    FRAGMENTS="$detected" out="$assemble_out" bash "$ASSEMBLE_SCRIPT"
    cp "$assemble_out/lefthook.yml" lefthook.yml
    rm -rf "$assemble_out"
}

@test "--dry-run prints check plan and exits 0" {
    export CONFIRM_DRY_RUN="1"
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"dry-run"* ]]
    [[ "$output" == *"detected fragments"* ]]
    [[ "$output" == *"standard rev"* ]]
}

@test "passes on correctly materialized repo" {
    materialize_basic
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"confirmed:"* ]]
    [[ "$output" == *"drift=none"* ]]
    [[ "$output" == *"0 failed"* ]]
}

@test "fails when lefthook.yml missing" {
    cp "$SETTING_SRC/.markdownlint.yml" .markdownlint.yml
    cp "$SETTING_SRC/.yamllint.yml" .yamllint.yml
    touch flake.lock
    git add .
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL: completeness: lefthook.yml missing"* ]]
}

@test "fails when config file missing" {
    local assemble_out
    assemble_out="$(mktemp -d)"
    FRAGMENTS="base" out="$assemble_out" bash "$ASSEMBLE_SCRIPT"
    cp "$assemble_out/lefthook.yml" lefthook.yml
    rm -rf "$assemble_out"
    touch flake.lock
    git add .
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL: completeness: .markdownlint.yml missing"* ]]
}

@test "fails on fidelity mismatch" {
    materialize_basic
    printf '%s\n' "modified" >> lefthook.yml
    git add .
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL: fidelity: lefthook.yml differs"* ]]
}

@test "fails when rev is unknown" {
    materialize_basic
    export CONFIRM_REV="unknown"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL: binding-integrity: standard rev unknown"* ]]
}

@test "fails when lefthook.yml has legacy remotes" {
    materialize_basic
    printf '\nremotes:\n  - git_url: http://example.com\n' >> lefthook.yml
    git add .
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL: no-drift: lefthook.yml contains legacy remotes"* ]]
}

@test "fails when flake.lock missing" {
    local assemble_out
    assemble_out="$(mktemp -d)"
    FRAGMENTS="base" out="$assemble_out" bash "$ASSEMBLE_SCRIPT"
    cp "$assemble_out/lefthook.yml" lefthook.yml
    rm -rf "$assemble_out"
    cp "$SETTING_SRC/.markdownlint.yml" .markdownlint.yml
    cp "$SETTING_SRC/.yamllint.yml" .yamllint.yml
    git add .
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL: binding-integrity: flake.lock missing"* ]]
}

@test "summary includes fragment list and rev" {
    materialize_basic
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"fragments ["* ]]
    [[ "$output" == *"@abc1234"* ]]
}

@test "ci-contexts: passes when ci.yml delegates to guardrails" {
    export REQUIRED_STATUS_CONTEXTS="guardrails / check|guardrails / check-darwin"
    mkdir -p .github/workflows
    printf '%s\n' \
        'name: CI' \
        '"on": { push: { branches: [main] } }' \
        'jobs:' \
        '  guardrails:' \
        '    uses: pr0d1r2/set-and-setting/.github/workflows/guardrails.yml@main' \
        > .github/workflows/ci.yml
    materialize_basic
    run bash "$SCRIPT"
    [[ "$output" == *"PASS: ci-contexts"* ]]
}

@test "ci-contexts: fails when ci.yml is not guardrails caller" {
    export REQUIRED_STATUS_CONTEXTS="guardrails / check|guardrails / check-darwin"
    mkdir -p .github/workflows
    printf '%s\n' \
        'name: CI' \
        '"on": { push: { branches: [main] } }' \
        'jobs:' \
        '  build-linux:' \
        '    runs-on: ubuntu-latest' \
        '    steps: [{ uses: "actions/checkout@v4" }]' \
        > .github/workflows/ci.yml
    materialize_basic
    run bash "$SCRIPT"
    [[ "$output" == *"FAIL: ci-contexts"* ]]
}

@test "ci-contexts: skipped when no REQUIRED_STATUS_CONTEXTS" {
    materialize_basic
    unset REQUIRED_STATUS_CONTEXTS
    run bash "$SCRIPT"
    ! [[ "$output" == *"ci-contexts"* ]]
}

@test "ci-contexts: skipped when no ci.yml" {
    materialize_basic
    export REQUIRED_STATUS_CONTEXTS="guardrails / check|guardrails / check-darwin"
    run bash "$SCRIPT"
    ! [[ "$output" == *"ci-contexts"* ]]
}
