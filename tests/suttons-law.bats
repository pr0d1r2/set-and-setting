#!/usr/bin/env bats
# Contract coverage for the Sutton's law principle (#273).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/principles"
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/sutton.md" \
        "$SKILLS_DIR/principles/sutton.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable principle carries Sutton's diagnostic guidance" {
    CAT=principles KEYWORDS=suttons-law GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-principles/SKILL.md"

    grep -qF "# Sutton's law" "$skill"
    grep -qF 'State the observed failure before naming a cause' "$skill"
    grep -qF 'Rank plausible causes using the current evidence' "$skill"
    grep -qF 'information gained relative to its cost' "$skill"
    grep -qF 'Define in advance what result would confirm or rule out' "$skill"
    grep -qF 'Inspect the direct path to the suspected source' "$skill"
    grep -qF 'Escalate deliberately' "$skill"
    grep -qF 'Preserve high-consequence alternatives' "$skill"
    grep -qF 'not proof that the obvious answer is' "$skill"
}
