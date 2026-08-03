#!/usr/bin/env bats
# Contract coverage for the Simon Effect autonomy skill (#275).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/psychology"
    cp "$BATS_TEST_DIRNAME/../set/skills/psychology/simon.md" \
        "$SKILLS_DIR/psychology/simon.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable psychology skill carries Simon-effect autonomy safeguards" {
    CAT=psychology KEYWORDS=simon-effect GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-psychology/SKILL.md"

    grep -qF '# Autonomy: Simon effect' "$skill"
    grep -qF 'Define the response rule before inspecting the choices' "$skill"
    grep -qF 'Separate identity from location' "$skill"
    grep -qF 'Pause when the relevant answer conflicts' "$skill"
    grep -qF 'Re-map the presentation and repeat the decision' "$skill"
    grep -qF 'Verify consequential actions against the target' "$skill"
    grep -qF 'Design interfaces so placement supports' "$skill"
    grep -qF 'Measure the effect before attributing it' "$skill"
    grep -qF 'does not show that choices are never autonomous' "$skill"
}
