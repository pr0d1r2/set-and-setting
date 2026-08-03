#!/usr/bin/env bats
# Contract coverage for the Wiio's laws principle (#272).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/principles"
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/wiio.md" \
        "$SKILLS_DIR/principles/wiio.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable principle carries Wiio's communication guidance" {
    CAT=principles KEYWORDS=wiios-laws GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-principles/SKILL.md"

    grep -qF "# Wiio's laws" "$skill"
    grep -qF "Start from the receiver's context" "$skill"
    grep -qF 'Search for the most damaging plausible interpretation' "$skill"
    grep -qF 'Close the loop on consequential messages' "$skill"
    grep -qF 'Treat agent handoffs as communication across unequal contexts' \
        "$skill"
    grep -qF 'Prefer one authoritative message' "$skill"
    grep -qF 'Match the channel to the consequence' "$skill"
    grep -qF 'use a checklist for essentials' "$skill"
    grep -qF 'inspect how the message will appear' "$skill"
    grep -qF 'not proof that every' "$skill"
}
