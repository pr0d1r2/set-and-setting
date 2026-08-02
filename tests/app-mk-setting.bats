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
    COVERAGE_SCRIPT="$BATS_TEST_DIRNAME/../lib/check-coverage.sh"
    FRAGMENTS_DIR="$BATS_TEST_DIRNAME/../setting/integrations/lefthook"
    CHECKS_UNIVERSE="gitleaks git-conflict-markers git-no-local-paths execute-permissions file-size-check trailing-whitespace missing-final-newline editorconfig-checker typos flake-manifest nixfmt statix deadnix nix-no-embedded-shell shellcheck shfmt no-shell-functions ascii-only"

    echo "markdownlint config" >"$SETTING_SRC/.markdownlint.yml"
    echo "yamllint config" >"$SETTING_SRC/.yamllint.yml"

    cd "$TARGET" || exit 1
    git init --quiet
    git config user.email "test@test.com"
    git config user.name "Test"

    export SETTING_SRC ASSEMBLE_SCRIPT DETECT_SCRIPT COVERAGE_SCRIPT
    export FRAGMENTS_DIR CHECKS_UNIVERSE
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
    # #102 FLIP: no remotes in emitted lefthook.
    run ! grep -q 'remotes:' "$TARGET/lefthook.yml"
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

@test "content-aware: ruby repo with .rubocop.yml assembles rubocop hook" {
    printf '%s\n' 'AllCops:' >"$TARGET/.rubocop.yml"
    printf '%s\n' 'puts "hello"' >"$TARGET/example.rb"
    git -C "$TARGET" add .rubocop.yml example.rb

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [[ "$output" == *"rubocop"* ]]
    grep -q 'rubocop:' "$TARGET/lefthook.yml"
    grep -q 'bundle exec rubocop --fail-fast --force-exclusion {staged_files}' \
        "$TARGET/lefthook.yml"
}

@test "content-aware: ruby repo with spec directory assembles rspec hook" {
    mkdir -p "$TARGET/spec"
    printf '%s\n' 'RSpec.describe "example"' >"$TARGET/spec/example_spec.rb"
    git -C "$TARGET" add spec/example_spec.rb

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [[ "$output" == *"rspec"* ]]
    grep -q 'rspec:' "$TARGET/lefthook.yml"
    grep -q 'bundle exec rspec' "$TARGET/lefthook.yml"
}

@test "content-aware: ruby repo assembles extended guardrails" {
    mkdir -p "$TARGET/config"
    printf '%s\n' 'detectors:' >"$TARGET/.reek.yml"
    printf '%s\n' 'skip_files: []' >"$TARGET/config/brakeman.yml"
    printf '%s\n' 'GEM' >"$TARGET/Gemfile.lock"
    git -C "$TARGET" add .reek.yml config/brakeman.yml Gemfile.lock

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [[ "$output" == *"reek"* ]]
    [[ "$output" == *"brakeman"* ]]
    [[ "$output" == *"bundle-audit"* ]]
    grep -q 'bundle exec reek {staged_files}' "$TARGET/lefthook.yml"
    grep -q 'bundle exec brakeman --no-pager -q' "$TARGET/lefthook.yml"
    grep -q 'bundle exec bundle-audit check --update' "$TARGET/lefthook.yml"
}

@test "output message includes detected fragments" {
    printf '' >"$TARGET/test.nix"
    git -C "$TARGET" add test.nix
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"lefthook:"* ]]
    [[ "$output" == *"nix"* ]]
}

@test "vendored remotes without checksFor are refused and left intact" {
    printf '%s\n' \
        "---" \
        "remotes:" \
        "  - git_url: https://github.com/pr0d1r2/nix-lefthook-git-no-local-paths" \
        "    ref: main" \
        >lefthook.yml
    before="$(cat lefthook.yml)"

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"model: vendored"* ]]
    [[ "$output" == *"migrate first"* ]]
    [ "$(cat lefthook.yml)" = "$before" ]
    [ ! -f .markdownlint.yml ]
}

@test "checksFor mentioned only in comments does not certify coverage" {
    printf '%s\n' \
        "---" \
        "remotes:" \
        "  - git_url: https://github.com/pr0d1r2/nix-lefthook-nixfmt" \
        >lefthook.yml
    printf '%s\n' \
        '# TODO: migrate to checksFor before refreshing' \
        '/* example migration:' \
        '   checks = checksFor { };' \
        '*/' \
        'example = "checksFor { is not active here";' \
        "example2 = ''checksFor { is not active here'';" \
        >flake.nix
    before="$(cat lefthook.yml)"

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"vendored lefthook remotes require migration"* ]]
    [ "$(cat lefthook.yml)" = "$before" ]
    [ ! -f .markdownlint.yml ]
}

@test "referenced model preserves vendored identities through checksFor" {
    printf '%s\n' \
        "---" \
        "remotes:" \
        "  - git_url: https://github.com/pr0d1r2/nix-lefthook-git-no-local-paths.git" \
        "  - git_url: https://github.com/pr0d1r2/nix-lefthook-nixfmt" \
        "  - git_url: https://github.com/pr0d1r2/nix-lefthook-shellcheck" \
        "  - git_url: https://github.com/pr0d1r2/nix-lefthook-statix" \
        "  - git_url: https://github.com/pr0d1r2/nix-lefthook-deadnix" \
        >lefthook.yml
    echo '{ checks = checksFor { }; }' >flake.nix
    git add flake.nix

    run bash "$SCRIPT"

    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS: coverage"* ]]
    run ! grep -q '^remotes:' lefthook.yml
}

@test "coverage backstop ignores inactive checksFor examples" {
    printf '%s\n' \
        "pre-commit:" \
        "  commands:" \
        "    nixfmt:" \
        "      run: nixfmt {staged_files}" \
        >lefthook.yml
    printf '%s\n' \
        '/* checks = checksFor { }; */' \
        'example = "checksFor { is not active here";' \
        >flake.nix

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"dropped: nixfmt"* ]]
}

@test "coverage backstop reports dropped custom local commands" {
    printf '%s\n' \
        "---" \
        "pre-commit:" \
        "  commands:" \
        "    repo-own-linter:" \
        "      run: repo-own-linter {staged_files}" \
        >lefthook.yml
    before="$(cat lefthook.yml)"

    run bash "$SCRIPT"

    [ "$status" -ne 0 ]
    [[ "$output" == *"COVERAGE-FAIL"* ]]
    [[ "$output" == *"dropped: repo-own-linter"* ]]
    [ "$(cat lefthook.yml)" = "$before" ]
}
