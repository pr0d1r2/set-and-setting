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

@test "source-tree mode detects files before git init" {
    source_tree="$(mktemp -d)"
    mkdir -p "$source_tree/.github/workflows"
    touch "$source_tree/flake.nix" "$source_tree/README.md"
    touch "$source_tree/.github/workflows/ci.yml"
    run env DETECT_ROOT="$source_tree" bash "$SCRIPT"
    rm -rf "$source_tree"
    [ "$status" -eq 0 ]
    [ "$output" = "base actions nix ascii markdown yaml" ]
}

@test "empty source-tree mode does not over-detect optional fragments" {
    source_tree="$(mktemp -d)"
    run env DETECT_ROOT="$source_tree" bash "$SCRIPT"
    rm -rf "$source_tree"
    [ "$status" -eq 0 ]
    [ "$output" = "base ascii" ]
}

@test "empty repo defaults to all fragments" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base actions nix shell ruby rubocop rspec reek brakeman bundle-audit ascii markdown yaml set" ]
}

@test "Gemfile detects the Ruby fragment" {
    printf '%s\n' 'source "https://rubygems.org"' >Gemfile
    git add Gemfile
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ruby ascii" ]
}

@test "Gemfile selects the Ruby scaffold archetype" {
    printf '%s\n' 'source "https://rubygems.org"' >Gemfile
    git add Gemfile
    run env DETECT_ARCHETYPE=1 bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "ruby" ]
}

@test "gemspec selects the Ruby scaffold archetype" {
    printf '%s\n' 'Gem::Specification.new' >example.gemspec
    git add example.gemspec
    run env DETECT_ARCHETYPE=1 bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "ruby" ]
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

@test ".rubocop.yml detects rubocop" {
    printf '%s\n' 'AllCops:' >.rubocop.yml
    git add .rubocop.yml
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base rubocop ascii yaml" ]
}

@test "gemspec detects rubocop" {
    printf '%s\n' 'Gem::Specification.new' >example.gemspec
    git add example.gemspec
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ruby rubocop ascii" ]
}

@test "ruby source alone does not detect rubocop" {
    printf '%s\n' 'puts "hello"' >example.rb
    git add example.rb
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ascii" ]
}

@test "spec directory detects rspec" {
    mkdir -p spec/models
    printf '%s\n' 'RSpec.describe "example"' >spec/models/example_spec.rb
    git add spec/models/example_spec.rb
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base rspec ascii" ]
}

@test ".rspec detects rspec" {
    printf '%s\n' '--format documentation' >.rspec
    git add .rspec
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base rspec ascii" ]
}

@test "ruby source alone does not detect rspec" {
    printf '%s\n' 'puts "hello"' >example.rb
    git add example.rb
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ascii" ]
}

@test ".reek.yml detects reek" {
    printf '%s\n' 'detectors:' >.reek.yml
    git add .reek.yml
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base reek ascii yaml" ]
}

@test "config/brakeman.yml detects brakeman" {
    mkdir -p config
    printf '%s\n' 'skip_files: []' >config/brakeman.yml
    git add config/brakeman.yml
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base brakeman ascii yaml" ]
}

@test "Gemfile.lock detects bundle-audit" {
    printf '%s\n' 'GEM' >Gemfile.lock
    git add Gemfile.lock
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base bundle-audit ascii" ]
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
    mkdir -p set/skills
    printf '# Skill\n' >set/skills/test.md
    git add test.nix test.sh README.md config.yml set/skills/test.md
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base actions nix shell ascii markdown yaml set" ]
}

@test "fragment order is deterministic" {
    printf '' >test.nix
    printf 'key: value\n' >config.yml
    printf '# Title\n' >README.md
    printf '#!/bin/bash\n' >test.sh
    mkdir -p set/skills
    printf '# Skill\n' >set/skills/test.md
    git add config.yml README.md test.sh test.nix set/skills/test.md
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base actions nix shell ascii markdown yaml set" ]
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

@test "set/*.md tracked detects set fragment" {
    mkdir -p set/skills
    printf '# Skill\n' >set/skills/test.md
    git add set/skills/test.md
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ascii markdown set" ]
}

@test "set/*.md in subdirectory detected" {
    mkdir -p set/skills/nix
    printf '# Nix skill\n' >set/skills/nix/flake.md
    git add set/skills/nix/flake.md
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ascii markdown set" ]
}

@test "non-set markdown does not trigger set fragment" {
    printf '# Title\n' >README.md
    git add README.md
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base ascii markdown" ]
}

@test "set non-md file does not trigger set fragment" {
    mkdir -p set/lib
    printf 'data\n' >set/lib/build.nix
    git add set/lib/build.nix
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "base nix ascii" ]
}
