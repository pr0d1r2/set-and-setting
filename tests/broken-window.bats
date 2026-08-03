#!/usr/bin/env bats
# Contract coverage for the Broken Window principle (#267).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/principles"
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/brokenwindow.md" \
        "$SKILLS_DIR/principles/brokenwindow.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable principle carries broken-window debt guidance" {
    CAT=principles KEYWORDS=broken-window GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-principles/SKILL.md"

    grep -qF '# Broken window' "$skill"
    grep -qF 'Count the opportunity cost, not only the repair' "$skill"
    grep -qF 'Compare the cost of fixing now' "$skill"
    grep -qF 'Restore the lost capability before polishing it' "$skill"
    grep -qF 'Remove the cause with the symptom' "$skill"
    grep -qF 'Record deferred debt with evidence' "$skill"
    grep -qF 'Reinvest the saved maintenance effort' "$skill"
    grep -qF 'every imperfection deserves immediate removal' "$skill"
}
