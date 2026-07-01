#!/usr/bin/env bats

# Unit tests for lib/materialize-check.sh -- the materialization
# assertion engine. Verifies path-scoped rules layout (V17/V18/V19),
# frontmatter checks, glob values, exclude filtering, and no SKILL.md.

setup() {
    MATERIALIZED="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/materialize-check.sh"
    export MATERIALIZED
    export DIR=".claude/rules/set"
    export COND_FIELD="paths"
    export GLOBS_MAP="nix=**/*.nix,flake.lock;test=**/*.bats;generic=**/*"
    export EXCLUDE=""
}

teardown() {
    rm -rf "$MATERIALIZED"
}

make_rule_files() {
    local cat="$1"
    shift
    local globs=("$@")
    mkdir -p "$MATERIALIZED/$DIR/$cat"
    local fm="---"$'\n'"$COND_FIELD:"$'\n'
    for g in "${globs[@]}"; do
        fm+="  - \"$g\""$'\n'
    done
    fm+="---"$'\n'$'\n'
    printf '%s%s\n' "$fm" "$cat sub content" \
        >"$MATERIALIZED/$DIR/$cat/sub.md"
}

make_core_rule() {
    local cat="$1"
    shift
    local globs=("$@")
    mkdir -p "$MATERIALIZED/$DIR"
    local fm="---"$'\n'"$COND_FIELD:"$'\n'
    for g in "${globs[@]}"; do
        fm+="  - \"$g\""$'\n'
    done
    fm+="---"$'\n'$'\n'
    printf '%s%s\n' "$fm" "$cat core content" \
        >"$MATERIALIZED/$DIR/$cat.md"
}

@test "PASS when domain rule files have correct frontmatter" {
    make_rule_files nix "**/*.nix" "flake.lock"
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "PASS when core file exists with correct frontmatter" {
    make_core_rule nix "**/*.nix" "flake.lock"
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "FAIL when no rule files found for category" {
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"no rule files found"* ]]
}

@test "FAIL when rule file lacks conditional field" {
    mkdir -p "$MATERIALIZED/$DIR/nix"
    printf '%s\n' '# Nix' '' 'Nix content' \
        >"$MATERIALIZED/$DIR/nix/flake.md"
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"missing paths"* ]]
}

@test "FAIL when rule file is missing a glob value" {
    mkdir -p "$MATERIALIZED/$DIR/nix"
    printf '%s\n' '---' 'paths:' '  - "**/*.nix"' '---' '' 'Nix content' \
        >"$MATERIALIZED/$DIR/nix/flake.md"
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *'missing glob "flake.lock"'* ]]
}

@test "PASS when broad-glob category has correct frontmatter" {
    make_rule_files generic "**/*"
    CATEGORIES="generic" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "FAIL when excluded file is present in output" {
    make_rule_files generic "**/*"
    printf 'rtk content\n' >"$MATERIALIZED/$DIR/generic/rtk.md"
    CATEGORIES="generic" EXCLUDE="rtk.md" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"excluded file rtk.md"* ]]
}

@test "checks multiple categories in one run" {
    make_rule_files generic "**/*"
    make_rule_files nix "**/*.nix" "flake.lock"
    CATEGORIES="generic nix" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "checks both core file and subdir files" {
    make_core_rule nix "**/*.nix" "flake.lock"
    make_rule_files nix "**/*.nix" "flake.lock"
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

# --- CORE channel tests (V18/V32) ---

@test "PASS when core-channel category has path-less files" {
    mkdir -p "$MATERIALIZED/$DIR/generic"
    printf '%s\n' '# Skill' '' 'Body.' \
        >"$MATERIALIZED/$DIR/generic/skill.md"
    CATEGORIES="generic" CORE="generic" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "FAIL when core-channel file has frontmatter" {
    make_rule_files generic "**/*"
    CATEGORIES="generic" CORE="generic" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"must be path-less"* ]]
}

# --- Override tests (V30, mirrors emit-rule) ---

@test "override flips core-channel file to domain" {
    mkdir -p "$MATERIALIZED/$DIR/generic"
    printf '%s\n' '---' 'paths:' '  - "**/*"' '---' '' 'RTK body.' \
        >"$MATERIALIZED/$DIR/generic/rtk.md"
    printf '%s\n' '# Skill' '' 'Body.' \
        >"$MATERIALIZED/$DIR/generic/skill.md"
    CATEGORIES="generic" CORE="generic" \
        OVERRIDES="generic/rtk.md|domain|" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "subtree override applies to nested files (V30)" {
    mkdir -p "$MATERIALIZED/$DIR/test/qemu"
    printf '%s\n' '---' 'paths:' '  - "tests/integration/**"' '  - "**/*.exp"' '---' '' 'Cleanup.' \
        >"$MATERIALIZED/$DIR/test/qemu/cleanup.md"
    CATEGORIES="test" \
        OVERRIDES="test/qemu||tests/integration/**,**/*.exp" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "FAIL when subtree override globs missing from file" {
    mkdir -p "$MATERIALIZED/$DIR/test/qemu"
    printf '%s\n' '---' 'paths:' '  - "**/*.bats"' '---' '' 'Cleanup.' \
        >"$MATERIALIZED/$DIR/test/qemu/cleanup.md"
    CATEGORIES="test" \
        OVERRIDES="test/qemu||tests/integration/**,**/*.exp" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *'missing glob "tests/integration/**"'* ]]
}

@test "exact override wins over subtree prefix (V30)" {
    mkdir -p "$MATERIALIZED/$DIR/test/qemu"
    printf '%s\n' '---' 'paths:' '  - "**/*.nix"' '---' '' 'mDNS.' \
        >"$MATERIALIZED/$DIR/test/qemu/mdns.md"
    CATEGORIES="test" OVERRIDES="$(printf '%s\n%s\n' \
        'test/qemu||tests/integration/**,**/*.exp' \
        'test/qemu/mdns.md||**/*.nix')" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}
