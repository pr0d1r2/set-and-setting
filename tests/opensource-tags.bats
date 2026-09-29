#!/usr/bin/env bats

@test "opensource tags skill defines a shared release vocabulary" {
    local skill="$BATS_TEST_DIRNAME/../set/skills/opensource/tags.md"

    grep -q 'GitHub repository topics' "$skill"
    grep -q 'crates.io `keywords`' "$skill"
    grep -q 'canonical, lowercase, hyphen-separated tag list' "$skill"
    grep -q 'package.keywords' "$skill"
    grep -q 'package.categories' "$skill"
    grep -q 'A tag mismatch is release metadata drift' "$skill"
}

@test "opensource tags skill is markdown-only and tracked" {
    local skill="$BATS_TEST_DIRNAME/../set/skills/opensource/tags.md"

    [ -f "$skill" ]
    run file "$skill"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ASCII text"* || "$output" == *"Unicode text"* ]]
}
