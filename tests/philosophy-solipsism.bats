#!/usr/bin/env bats
# Contract coverage for the experimental Solipsism skill (#259).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/drafts/philosophy"
    cp "$BATS_TEST_DIRNAME/../set/drafts/philosophy/solipsism.md" \
        "$SKILLS_DIR/drafts/philosophy/solipsism.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable philosophy draft carries the Solipsism experiment" {
    CAT=drafts/philosophy KEYWORDS=philosophy GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-drafts/philosophy/SKILL.md"

    grep -qF '# Solipsism' "$skill"
    grep -qF 'Do not adopt metaphysical solipsism as a conclusion.' "$skill"
    grep -qF '1. **Experience**' "$skill"
    grep -qF '2. **Inference**' "$skill"
    grep -qF '3. **Probe**' "$skill"
    grep -qF '4. **Revision**' "$skill"
    grep -qF 'unfalsifiable and do not present it' "$skill"
    grep -qF 'Act on the shared-world model after the stress test.' "$skill"
}
