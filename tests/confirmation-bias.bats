#!/usr/bin/env bats
# Contract coverage for the Confirmation Bias skill (#263).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/bias"
    cp "$BATS_TEST_DIRNAME/../set/skills/bias/confirmation.md" \
        "$SKILLS_DIR/bias/confirmation.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable bias skill carries confirmation-bias countermeasures" {
    CAT=bias KEYWORDS=confirmation-bias GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-bias/SKILL.md"

    grep -qF '# Confirmation bias' "$skill"
    grep -qF 'Write down what would disprove the working hypothesis' "$skill"
    grep -qF 'Search for disconfirming evidence' "$skill"
    grep -qF 'Apply the same evidence standard' "$skill"
    grep -qF 'Record evidence that changed the conclusion' "$skill"
    grep -qF 'Do not manufacture false balance' "$skill"
}
