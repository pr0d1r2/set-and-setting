#!/usr/bin/env bats
# Contract coverage for the not-believing testing skill (#276).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/test"
    cp "$BATS_TEST_DIRNAME/../set/skills/test/not-believing.md" \
        "$SKILLS_DIR/test/not-believing.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable test skill requires observing an informative failure" {
    CAT=test KEYWORDS=not-believing GLOBS='**/*.bats' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-test/SKILL.md"

    grep -qF '# Test: not believing' "$skill"
    grep -qF 'Never trust a spec (test) you never saw failing' "$skill"
    grep -qF 'Run the narrowest relevant test before implementation' "$skill"
    grep -qF 'Confirm that it fails for the intended reason' "$skill"
    grep -qF 'A test that passes before the change proves nothing' "$skill"
    grep -qF 'restore the defect or temporarily reverse the condition' "$skill"
    grep -qF 'Keep every commit green' "$skill"
}
