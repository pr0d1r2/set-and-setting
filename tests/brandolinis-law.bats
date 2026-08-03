#!/usr/bin/env bats
# Contract coverage for the Brandolini's law adage (#270).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/adage"
    cp "$BATS_TEST_DIRNAME/../set/skills/adage/brandolinis-law.md" \
        "$SKILLS_DIR/adage/brandolinis-law.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable adage carries Brandolini's law guidance" {
    CAT=adage KEYWORDS=brandolinis-law GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-adage/SKILL.md"

    grep -qF "# Brandolini's law" "$skill"
    grep -qF 'Ask for a specific, testable claim' "$skill"
    grep -qF 'Keep the burden of proof with the claimant' "$skill"
    grep -qF 'Triage by reach, harm, audience, and reversibility' "$skill"
    grep -qF 'Check the original evidence' "$skill"
    grep -qF 'Correct clearly and proportionately' "$skill"
    grep -qF 'Reduce the asymmetry in advance' "$skill"
    grep -qF 'Prefer reusable corrections' "$skill"
    grep -qF 'Set a stopping condition' "$skill"
    grep -qF 'describes an effort imbalance' "$skill"
}
