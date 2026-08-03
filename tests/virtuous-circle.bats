#!/usr/bin/env bats
# Contract coverage for the Virtuous Circle principle (#266).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/principles"
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/virtuous.md" \
        "$SKILLS_DIR/principles/virtuous.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable principle carries virtuous-circle guidance" {
    CAT=principles KEYWORDS=virtuous-circle GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-principles/SKILL.md"

    grep -qF '# Virtuous circle' "$skill"
    grep -qF 'Draw the shortest causal chain you can defend' "$skill"
    grep -qF 'Seed the loop with the smallest useful input' "$skill"
    grep -qF 'Shorten and clarify feedback' "$skill"
    grep -qF 'Reinvest gains into the next iteration' "$skill"
    grep -qF 'Measure both the outcome and the loop' "$skill"
    grep -qF 'Add limits and exit conditions' "$skill"
    grep -qF 'A self-reinforcing loop is not inherently good' "$skill"
}
