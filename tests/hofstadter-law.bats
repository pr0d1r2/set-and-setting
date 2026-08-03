#!/usr/bin/env bats
# Contract coverage for the Hofstadter's Law principle (#265).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/principles"
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/hofstadter.md" \
        "$SKILLS_DIR/principles/hofstadter.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable principle carries Hofstadter's Law estimation guidance" {
    CAT=principles KEYWORDS=hofstadters-law GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-principles/SKILL.md"

    grep -qF "# Hofstadter's Law" "$skill"
    grep -qF 'Prefer reference-class evidence over intuition' "$skill"
    grep -qF 'Express meaningful uncertainty' "$skill"
    grep -qF 'Keep contingency explicit and protected' "$skill"
    grep -qF 'Create checkpoints that retire the largest unknowns early' "$skill"
    grep -qF 'Reduce scope or sequence delivery' "$skill"
    grep -qF 'does not justify indefinite schedules' "$skill"
}
