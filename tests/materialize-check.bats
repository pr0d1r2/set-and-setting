#!/usr/bin/env bats

# Unit tests for lib/materialize-check.sh -- the materialization
# assertion engine. Verifies domain vs always-on placement, frontmatter
# checks, exclude filtering, and facet-no-frontmatter (V25).

setup() {
    MATERIALIZED="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/materialize-check.sh"
    export MATERIALIZED
    export SKILL_PATH=".claude/skills/set"
    export RULE_PATH=".claude/rules"
    export COND_FIELD="paths"
    export GLOBS_MAP="nix=**/*.nix,flake.lock;test=**/*.bats"
    export EXCLUDE=""
}

teardown() {
    rm -rf "$MATERIALIZED"
}

make_domain_skill() {
    local cat="$1"
    mkdir -p "$MATERIALIZED/$SKILL_PATH/$cat"
    printf '%s\n' \
        '---' \
        "name: $cat" \
        "description: \"$cat\"" \
        'paths:' \
        '  - "**/*.nix"' \
        '  - "flake.lock"' \
        '---' \
        '' \
        "$cat content" \
        >"$MATERIALIZED/$SKILL_PATH/$cat/SKILL.md"
}

make_always_on_rule() {
    local cat="$1"
    mkdir -p "$MATERIALIZED/$RULE_PATH"
    printf '%s\n' \
        '---' \
        "name: $cat" \
        "description: \"$cat\"" \
        '---' \
        '' \
        "$cat content" \
        >"$MATERIALIZED/$RULE_PATH/$cat.md"
}

@test "PASS when domain skill has SKILL.md with correct frontmatter" {
    make_domain_skill nix
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "FAIL when domain SKILL.md is missing" {
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"SKILL.md missing"* ]]
}

@test "FAIL when domain SKILL.md lacks conditional field" {
    mkdir -p "$MATERIALIZED/$SKILL_PATH/nix"
    printf '%s\n' \
        '---' \
        'name: nix' \
        'description: "Nix"' \
        '---' \
        '' \
        'Nix content' \
        >"$MATERIALIZED/$SKILL_PATH/nix/SKILL.md"
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"missing paths"* ]]
}

@test "FAIL when domain SKILL.md is missing a glob value" {
    mkdir -p "$MATERIALIZED/$SKILL_PATH/nix"
    printf '%s\n' \
        '---' \
        'name: nix' \
        'description: "Nix"' \
        'paths:' \
        '  - "**/*.nix"' \
        '---' \
        '' \
        'Nix content' \
        >"$MATERIALIZED/$SKILL_PATH/nix/SKILL.md"
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *'missing glob "flake.lock"'* ]]
}

@test "PASS when always-on rule exists without conditional field" {
    make_always_on_rule generic
    CATEGORIES="generic" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "FAIL when always-on rule is missing" {
    CATEGORIES="generic" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"rule file missing"* ]]
}

@test "FAIL when always-on rule has conditional field" {
    mkdir -p "$MATERIALIZED/$RULE_PATH"
    printf '%s\n' \
        '---' \
        'name: generic' \
        'description: "Generic"' \
        'paths:' \
        '  - "**/*.md"' \
        '---' \
        '' \
        'Generic content' \
        >"$MATERIALIZED/$RULE_PATH/generic.md"
    CATEGORIES="generic" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"has paths field"* ]]
}

@test "FAIL when facet has frontmatter (V25 violation)" {
    make_domain_skill nix
    printf '%s\n' '---' 'name: flake' '---' '' 'Flake content' \
        >"$MATERIALIZED/$SKILL_PATH/nix/flake.md"
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"frontmatter"* ]]
}

@test "PASS when facets have no frontmatter" {
    make_domain_skill nix
    printf '%s\n' '# Nix: flake' '' 'Flake content' \
        >"$MATERIALIZED/$SKILL_PATH/nix/flake.md"
    CATEGORIES="nix" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}

@test "FAIL when excluded file is present in output" {
    make_always_on_rule generic
    mkdir -p "$MATERIALIZED/$SKILL_PATH/generic"
    printf 'rtk content\n' >"$MATERIALIZED/$SKILL_PATH/generic/rtk.md"
    CATEGORIES="generic" EXCLUDE="rtk.md" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"excluded file rtk.md"* ]]
}

@test "checks multiple categories in one run" {
    make_always_on_rule generic
    make_domain_skill nix
    CATEGORIES="generic nix" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}
