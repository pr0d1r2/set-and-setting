#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for setting/lib/assemble-lefthook.sh -- assembles lefthook.yml
# from integration fragments by merging remotes + pre-commit + pre-push.

write_remote() {
    printf '%s\n' "---" "remotes:" \
        "  - git_url: https://github.com/example/$1" \
        "    ref: main" "    configs:" "      - lefthook-remote.yml"
}

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

    write_remote hook-a >"$FRAGMENTS_DIR/base.yml"
    printf '%s\n' "  - git_url: https://github.com/example/hook-b" \
        "    ref: main" "    configs:" "      - lefthook-remote.yml" \
        >>"$FRAGMENTS_DIR/base.yml"
    write_remote hook-nix >"$FRAGMENTS_DIR/nix.yml"
    write_remote hook-shell >"$FRAGMENTS_DIR/shell.yml"

    {
        write_remote hook-ascii
        write_commands pre-commit ascii-check "*.nix" staged_files
        write_commands pre-push ascii-check "*.nix" push_files
    } >"$FRAGMENTS_DIR/ascii.yml"

    {
        write_remote hook-md
        write_commands pre-commit mdlint "*.md" staged_files
        write_commands pre-push mdlint "*.md" push_files
    } >"$FRAGMENTS_DIR/markdown.yml"

    {
        write_remote hook-yaml
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

@test "merges all remotes from all fragments" {
    bash "$SCRIPT"
    grep -c 'git_url:' "$out/lefthook.yml" | grep -q '^7$'
}

@test "remotes appear in fragment order" {
    bash "$SCRIPT"
    first_remote="$(grep 'git_url:' "$out/lefthook.yml" | head -1)"
    [[ "$first_remote" == *"hook-a"* ]]
    last_remote="$(grep 'git_url:' "$out/lefthook.yml" | tail -1)"
    [[ "$last_remote" == *"hook-yaml"* ]]
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
    for name in ascii markdown yaml; do
        write_remote "hook-$name" >"$FRAGMENTS_DIR/$name.yml"
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
    grep -q 'nix-lefthook-trailing-whitespace' "$out/lefthook.yml"
    grep -q 'nix-lefthook-nixfmt' "$out/lefthook.yml"
    grep -q 'nix-lefthook-yamllint' "$out/lefthook.yml"
    grep -q '^pre-commit:' "$out/lefthook.yml"
    grep -q '^pre-push:' "$out/lefthook.yml"
    grep -q 'markdownlint:' "$out/lefthook.yml"
    grep -q 'ascii-only:' "$out/lefthook.yml"
    grep -q 'yamllint:' "$out/lefthook.yml"
    grep -q 'set-ref-resolution:' "$out/lefthook.yml"
    grep -q 'set-bundle-content:' "$out/lefthook.yml"
}

@test "FRAGMENTS restricts included fragments" {
    FRAGMENTS="base markdown" bash "$SCRIPT"
    grep -q 'hook-a' "$out/lefthook.yml"
    grep -q 'hook-md' "$out/lefthook.yml"
    run ! grep -q 'hook-nix' "$out/lefthook.yml"
    run ! grep -q 'hook-shell' "$out/lefthook.yml"
    run ! grep -q 'hook-ascii' "$out/lefthook.yml"
    run ! grep -q 'hook-yaml' "$out/lefthook.yml"
    run ! grep -q 'set-ref-resolution' "$out/lefthook.yml"
}

@test "FRAGMENTS=base produces remotes-only output" {
    FRAGMENTS="base" bash "$SCRIPT"
    grep -q 'hook-a' "$out/lefthook.yml"
    run ! grep -q '^pre-commit:' "$out/lefthook.yml"
    run ! grep -q '^pre-push:' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+ascii includes ascii commands" {
    FRAGMENTS="base ascii" bash "$SCRIPT"
    grep -q 'hook-a' "$out/lefthook.yml"
    grep -q 'hook-ascii' "$out/lefthook.yml"
    grep -q 'ascii-check:' "$out/lefthook.yml"
    run ! grep -q 'hook-nix' "$out/lefthook.yml"
}

@test "FRAGMENTS with real fragments -- nix only" {
    local real_dir
    real_dir="$(cd "$BATS_TEST_DIRNAME/.." && pwd)/setting/integrations/lefthook"
    FRAGMENTS_DIR="$real_dir"
    export FRAGMENTS_DIR
    FRAGMENTS="base nix ascii" bash "$SCRIPT"
    grep -q 'nix-lefthook-trailing-whitespace' "$out/lefthook.yml"
    grep -q 'nix-lefthook-nixfmt' "$out/lefthook.yml"
    run ! grep -q 'nix-lefthook-shellcheck' "$out/lefthook.yml"
    run ! grep -q 'nix-lefthook-markdownlint' "$out/lefthook.yml"
    run ! grep -q 'nix-lefthook-yamllint' "$out/lefthook.yml"
    run ! grep -q 'set-ref-resolution' "$out/lefthook.yml"
}

@test "FRAGMENTS=base+set includes set commands" {
    FRAGMENTS="base set" bash "$SCRIPT"
    grep -q 'hook-a' "$out/lefthook.yml"
    grep -q 'set-ref-resolution:' "$out/lefthook.yml"
    run ! grep -q 'hook-nix' "$out/lefthook.yml"
    run ! grep -q 'hook-md' "$out/lefthook.yml"
}

@test "set fragment has no remotes" {
    FRAGMENTS="set" bash "$SCRIPT"
    local remote_count
    remote_count="$(grep -c 'git_url:' "$out/lefthook.yml" || true)"
    [ "$remote_count" -eq 0 ]
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
