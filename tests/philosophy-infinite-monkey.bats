#!/usr/bin/env bats
# Contract coverage for the experimental Infinite Monkey skill (#260).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/drafts/philosophy"
    cp "$BATS_TEST_DIRNAME/../set/drafts/philosophy/infinite-monkey.md" \
        "$SKILLS_DIR/drafts/philosophy/infinite-monkey.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable philosophy draft carries the Infinite Monkey experiment" {
    CAT=drafts/philosophy KEYWORDS=philosophy GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-drafts/philosophy/SKILL.md"

    grep -qF '# Infinite Monkey' "$skill"
    grep -qF 'Almost sure is not the same as certain' "$skill"
    grep -qF 'Do not use the theorem to justify blind random search.' "$skill"
    grep -qF '1. **Target**' "$skill"
    grep -qF '2. **Generator**' "$skill"
    grep -qF '3. **Oracle**' "$skill"
    grep -qF '4. **Budget**' "$skill"
    grep -qF '5. **Learning**' "$skill"
    grep -qF 'Stop when the budget expires' "$skill"
}
