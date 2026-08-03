#!/usr/bin/env bats
# Contract coverage for the Hindsight Bias skill (#264).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/bias"
    cp "$BATS_TEST_DIRNAME/../set/skills/bias/hindsight.md" \
        "$SKILLS_DIR/bias/hindsight.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable bias skill carries hindsight-bias countermeasures" {
    CAT=bias KEYWORDS=hindsight-bias GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-bias/SKILL.md"

    grep -qF '# Hindsight bias' "$skill"
    grep -qF 'Preserve the contemporaneous record' "$skill"
    grep -qF 'Reconstruct the decision point without outcome knowledge' "$skill"
    grep -qF 'Consider the opposite' "$skill"
    grep -qF 'Separate decision quality from outcome quality' "$skill"
    grep -qF 'Do not use uncertainty to excuse ignored evidence' "$skill"
}
