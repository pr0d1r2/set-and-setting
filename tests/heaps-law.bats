#!/usr/bin/env bats
# Contract coverage for the Heaps's Law principle (#269).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/principles"
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/heaps.md" \
        "$SKILLS_DIR/principles/heaps.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable principle carries Heaps's Law context guidance" {
    CAT=principles KEYWORDS=heaps-law GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-principles/SKILL.md"

    grep -qF "# Heaps's Law" "$skill"
    grep -qF 'Treat token count and information coverage as different measures' \
        "$skill"
    grep -qF 'Inventory distinct context before shrinking it' "$skill"
    grep -qF 'Remove redundancy first' "$skill"
    grep -qF 'Protect rare, consequential details explicitly' "$skill"
    grep -qF 'Preserve retrieval handles' "$skill"
    grep -qF 'Shrink in layers' "$skill"
    grep -qF 'Test the shrunken context' "$skill"
    grep -qF 'Measure repeated shrinkification as a lossy pipeline' "$skill"
    grep -qF 'not semantic' "$skill"
    grep -qF 'importance and not a compression algorithm' "$skill"
}
