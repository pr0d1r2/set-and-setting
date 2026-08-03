#!/usr/bin/env bats
# Contract coverage for the Stroop Effect psychology skill (#274).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/psychology"
    cp "$BATS_TEST_DIRNAME/../set/skills/psychology/stroop.md" \
        "$SKILLS_DIR/psychology/stroop.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable psychology skill carries Stroop countermeasures" {
    CAT=psychology KEYWORDS=stroop-effect GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-psychology/SKILL.md"

    grep -qF '# Stroop effect' "$skill"
    grep -qF 'State the target dimension before inspecting the evidence' "$skill"
    grep -qF 'Separate conflicting cues' "$skill"
    grep -qF 'Slow down when automatic and task-relevant responses disagree' "$skill"
    grep -qF 'Name both observations precisely' "$skill"
    grep -qF 'Verify the relevant dimension through an independent representation' \
        "$skill"
    grep -qF 'Design interfaces to reduce avoidable conflict' "$skill"
    grep -qF 'Measure interference when it matters' "$skill"
    grep -qF 'does not prove that every mistake comes from automatic processing' \
        "$skill"
}
