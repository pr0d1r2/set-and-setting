#!/usr/bin/env bats
# Contract coverage for the Assumptions principle (#496).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/principles"
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/assumptions.md" \
        "$SKILLS_DIR/principles/assumptions.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable principle carries assumption-proof guidance" {
    CAT=principles KEYWORDS=assumption-testing GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-principles/SKILL.md"

    grep -qF '# Assumptions' "$skill"
    grep -qF 'observable acceptance' "$skill"
    grep -qF 'criterion' "$skill"
    grep -qF 'Make the test fail before trusting it' "$skill"
    grep -qF 'dual-band mutation testing' "$skill"
    grep -qF 'mutate the' "$skill"
    grep -qF 'implementation' "$skill"
    grep -qF 'test or its fixture' "$skill"
    grep -qF 'cheap, high-signal' "$skill"
    grep -qF 'verified facts, remaining assumptions, and untested risks' "$skill"
}
