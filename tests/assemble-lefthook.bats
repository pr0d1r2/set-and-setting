#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for setting/lib/assemble-lefthook.sh -- assembles lefthook.yml
# from integration fragments by merging pre-commit + pre-push sections.
# No remotes: block -- all linters are pinned flake checks (#102 FLIP).

write_commands() {
    printf '\n%s\n' "$1:"
    printf '%s\n' "  commands:" \
        "    $2:" "      glob: \"$3\"" \
        "      run: lefthook-$2 {$4}"
}

setup() {
    bats_require_minimum_version 1.5.0
    FRAGMENTS_DIR="$(mktemp -d)"
    _ORIG_FRAGMENTS_DIR="$FRAGMENTS_DIR"
    export out
    out="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../setting/lib/assemble-lefthook.sh"

    printf '%s\n' "---" >"$FRAGMENTS_DIR/base.yml"

    printf '%s\n' "---" >"$FRAGMENTS_DIR/nix.yml"
    printf '%s\n' "---" >"$FRAGMENTS_DIR/shell.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit rubocop "**/*.rb" staged_files
        write_commands pre-push rubocop "**/*.rb" push_files
    } >"$FRAGMENTS_DIR/rubocop.yml"

    {
        printf '%s\n' "---"
        write_commands pre-push rspec "**/*_spec.rb" push_files
    } >"$FRAGMENTS_DIR/rspec.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit ascii-check "*.nix" staged_files
        write_commands pre-push ascii-check "*.nix" push_files
    } >"$FRAGMENTS_DIR/ascii.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit mdlint "*.md" staged_files
        write_commands pre-push mdlint "*.md" push_files
    } >"$FRAGMENTS_DIR/markdown.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit yamllint "*.yml" staged_files
        write_commands pre-push yamllint "*.yml" push_files
    } >"$FRAGMENTS_DIR/yaml.yml"

    {
        printf '%s\n' "---"
        write_commands pre-commit set-ref-resolution "set/**/*.md" staged_files
        write_commands pre-push set-ref-resolution "set/**/*.md" push_files
    } >"$FRAGMENTS_DIR/set.yml"

    export FRAGMENTS_DIR
}

teardown() {
    rm -rf "$_ORIG_FRAGMENTS_DIR" "$out"
}

@test "produces lefthook.yml" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -f "$out/lefthook.yml" ]
}

@test "output starts with YAML document marker" {
    bash "$SCRIPT"
    head -1 "$out/lefthook.yml" | grep -q '^---$'
}

@test "no remotes block in output" {
    bash "$SCRIPT"
    run ! grep -q 'remotes:' "$out/lefthook.yml"
    run ! grep -q 'git_url:' "$out/lefthook.yml"
}

@test "has pre-commit section with commands" {
    bash "$SCRIPT"
    grep -q '^pre-commit:' "$out/lefthook.yml"
    grep -q '  commands:' "$out/lefthook.yml"
}

@test "pre-commit merges commands from all fragments" {
    bash "$SCRIPT"
    grep -q 'ascii-check:' "$out/lefthook.yml"
    grep -q 'mdlint:' "$out/lefthook.yml"
    grep -q 'yamllint:' "$out/lefthook.yml"
    grep -q 'set-ref-resolution:' "$out/lefthook.yml"
}

@test "has pre-push section with commands" {
    bash "$SCRIPT"
    grep -q '^pre-push:' "$out/lefthook.yml"
    grep -q 'push_files' "$out/lefthook.yml"
}

@test "pre-push merges commands from all fragments" {
    bash "$SCRIPT"
    local prepush_section
    prepush_section="$(awk '/^pre-push:/,0' "$out/lefthook.yml")"
    echo "$prepush_section" | grep -q 'ascii-check:'
    echo "$prepush_section" | grep -q 'mdlint:'
    echo "$prepush_section" | grep -q 'yamllint:'
    echo "$prepush_section" | grep -q 'set-ref-resolution:'
}

@test "fragments without commands do not add empty sections" {
    for name in ascii markdown yaml rubocop rspec; do
        printf '%s\n' "---" >"$FRAGMENTS_DIR/$name.yml"
    done
    printf '%s\n' "---" >"$FRAGMENTS_DIR/set.yml"
    bash "$SCRIPT"
    run ! grep -q '^pre-commit:' "$out/lefthook.yml"
    run ! grep -q '^pre-push:' "$out/lefthook.yml"
}

@test "assembles real fragments from setting/integrations/lefthook" {
    local real_dir
    real_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/setting/integrations/lefthook"
    FRAGMENTS_DIR="$real_dir"
    export FRAGMENTS_DIR
    bash "$SCRIPT"
    [ -f "$out/lefthook.yml" ]
    # #102 FLIP: no remotes anywhere in the emitted lefthook.
    run ! grep -q 'remotes:' "$out/lefthook.yml"
    run ! grep -q 'git_url:' "$out/lefthook.yml"
    grep -q '^pre-commit:' "$out/lefthook.yml"
    grep -q '^pre-push:' "$out/lefthook.yml"
    grep -q 'markdownlint:' "$out/lefthook.yml"
    grep -q 'yamllint:' "$out/lefthook.yml"
    grep -q 'set-ref-resolution:' "$out/lefthook.yml"
    grep -q 'set-bundle-content:' "$out/lefthook.yml"
    grep -q 'rubocop:' "$out/lefthook.yml"
    grep -q 'rspec:' "$out/lefthook.yml"
    grep -q 'bundle exec rspec' "$out/lefthook.yml"
    grep -q 'bundle exec rubocop --fail-fast --force-exclusion {staged_files}' \
        "$out/lefthook.yml"
}

@test "FRAGMENTS restricts included fragments" {
    FRAGMENTS="base markdown" bash "$SCRIPT"
    grep -q 'mdlint' "$out/lefthook.yml"
    run ! grep -q 'yamllint' "$out/lefthook.yml"
    run ! grep -q 'ascii-check' "$out/lefthook.yml"
    run ! grep -q 'set-ref-resolution' "$out/lefthook.yml"
}

@test "FRAGMENTS=base produces commands-only output" {
    FRAGMENTS="base" bash "$SCRIPT"
    run ! grep -q '^pre-commit:' "$out/lefthook.yml"
    run ! grep -q '^pre-push:' "$out/lefthook.yml"
    run ! grep -q 'remotes:' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+ascii includes ascii commands" {
    FRAGMENTS="base ascii" bash "$SCRIPT"
    grep -q 'ascii-check:' "$out/lefthook.yml"
    run ! grep -q 'yamllint' "$out/lefthook.yml"
}

@test "FRAGMENTS with real fragments -- nix only" {
    local real_dir
    real_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/setting/integrations/lefthook"
    FRAGMENTS_DIR="$real_dir"
    export FRAGMENTS_DIR
    FRAGMENTS="base nix ascii" bash "$SCRIPT"
    # #102 FLIP: no remotes from any fragment.
    run ! grep -q 'remotes:' "$out/lefthook.yml"
    run ! grep -q 'git_url:' "$out/lefthook.yml"
    run ! grep -q 'nix-lefthook-markdownlint' "$out/lefthook.yml"
    run ! grep -q 'nix-lefthook-yamllint' "$out/lefthook.yml"
    run ! grep -q 'set-ref-resolution' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+set includes set commands" {
    FRAGMENTS="base set" bash "$SCRIPT"
    grep -q 'set-ref-resolution:' "$out/lefthook.yml"
    run ! grep -q 'mdlint' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+rubocop includes only rubocop commands" {
    FRAGMENTS="base rubocop" bash "$SCRIPT"
    grep -q 'rubocop:' "$out/lefthook.yml"
    run ! grep -q 'mdlint' "$out/lefthook.yml"
    run ! grep -q 'yamllint' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+rspec includes only rspec commands" {
    FRAGMENTS="base rspec" bash "$SCRIPT"
    grep -q 'rspec:' "$out/lefthook.yml"
    run ! grep -q 'rubocop' "$out/lefthook.yml"
    run ! grep -q 'mdlint' "$out/lefthook.yml"
    run ! grep -q 'yamllint' "$out/lefthook.yml"
}

@test "no remotes even with set-only fragment" {
    FRAGMENTS="set" bash "$SCRIPT"
    run ! grep -q 'remotes:' "$out/lefthook.yml"
    run ! grep -q 'git_url:' "$out/lefthook.yml"
}

@test "set fragment commands in pre-commit and pre-push" {
    FRAGMENTS="base set" bash "$SCRIPT"
    local precommit_section prepush_section
    precommit_section="$(awk '/^pre-commit:/,/^pre-push:/' "$out/lefthook.yml")"
    prepush_section="$(awk '/^pre-push:/,0' "$out/lefthook.yml")"
    echo "$precommit_section" | grep -q 'set-ref-resolution:'
    echo "$prepush_section" | grep -q 'set-ref-resolution:'
}

@test "real set fragment includes both checks" {
    local real_dir
    real_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/setting/integrations/lefthook"
    FRAGMENTS_DIR="$real_dir"
    export FRAGMENTS_DIR
    FRAGMENTS="base set" bash "$SCRIPT"
    grep -q 'set-ref-resolution:' "$out/lefthook.yml"
    grep -q 'set-bundle-content:' "$out/lefthook.yml"
    grep -q 'ref-resolve-check.sh' "$out/lefthook.yml"
    grep -q 'bundle-content-check.sh' "$out/lefthook.yml"
}

# ======== repo-local fragment (#126) ========

@test "lefthook-repo.yml in CWD is included in assembly" {
    local workdir
    workdir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit taplo "*.toml" staged_files
        write_commands pre-push taplo "*.toml" push_files
    } >"$workdir/lefthook-repo.yml"
    cd "$workdir"
    bash "$SCRIPT"
    grep -q 'taplo:' "$out/lefthook.yml"
    grep -q 'lefthook-taplo' "$out/lefthook.yml"
    # standard fragment commands also present
    grep -q 'ascii-check:' "$out/lefthook.yml"
    grep -q 'mdlint:' "$out/lefthook.yml"
    rm -rf "$workdir"
}

@test "repo-local pre-commit commands merge with standard fragments" {
    local workdir
    workdir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit taplo "*.toml" staged_files
    } >"$workdir/lefthook-repo.yml"
    cd "$workdir"
    bash "$SCRIPT"
    local precommit_section
    precommit_section="$(awk '/^pre-commit:/,/^pre-push:/' "$out/lefthook.yml")"
    echo "$precommit_section" | grep -q 'taplo:'
    echo "$precommit_section" | grep -q 'ascii-check:'
    rm -rf "$workdir"
}

@test "repo-local pre-push commands merge with standard fragments" {
    local workdir
    workdir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-push taplo "*.toml" push_files
    } >"$workdir/lefthook-repo.yml"
    cd "$workdir"
    bash "$SCRIPT"
    local prepush_section
    prepush_section="$(awk '/^pre-push:/,0' "$out/lefthook.yml")"
    echo "$prepush_section" | grep -q 'taplo:'
    echo "$prepush_section" | grep -q 'ascii-check:'
    rm -rf "$workdir"
}

@test "no lefthook-repo.yml means no repo-local commands" {
    local workdir
    workdir="$(mktemp -d)"
    cd "$workdir"
    bash "$SCRIPT"
    run ! grep -q 'taplo' "$out/lefthook.yml"
    rm -rf "$workdir"
}

@test "repo-local fragment alone creates hook sections" {
    # All standard fragments empty -- repo-local is the only source
    for name in base nix shell rubocop rspec ascii markdown yaml set; do
        printf '%s\n' "---" >"$FRAGMENTS_DIR/$name.yml"
    done
    local workdir
    workdir="$(mktemp -d)"
    {
        printf '%s\n' "---"
        write_commands pre-commit taplo "*.toml" staged_files
    } >"$workdir/lefthook-repo.yml"
    cd "$workdir"
    bash "$SCRIPT"
    grep -q '^pre-commit:' "$out/lefthook.yml"
    grep -q 'taplo:' "$out/lefthook.yml"
    rm -rf "$workdir"
}
