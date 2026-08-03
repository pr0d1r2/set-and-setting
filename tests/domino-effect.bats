#!/usr/bin/env bats
# Contract coverage for the Domino Effect principle (#268).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/principles"
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/domino.md" \
        "$SKILLS_DIR/principles/domino.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable principle carries domino-effect cascade guidance" {
    CAT=principles KEYWORDS=domino-effect GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-principles/SKILL.md"

    grep -qF '# Domino effect' "$skill"
    grep -qF 'Draw the causal chain one link at a time' "$skill"
    grep -qF 'Test the weakest link first' "$skill"
    grep -qF 'Estimate reach and timing' "$skill"
    grep -qF 'Place circuit breakers at high-leverage links' "$skill"
    grep -qF 'Observe links, not only endpoints' "$skill"
    grep -qF 'Prefer reversible initiation' "$skill"
    grep -qF 'does not prove that every remaining domino must fall' "$skill"
    grep -qF 'Keep possibility separate from probability' "$skill"
}
