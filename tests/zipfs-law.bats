#!/usr/bin/env bats
# Contract coverage for the Zipf's Law language skill (#271).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/language"
    cp "$BATS_TEST_DIRNAME/../set/skills/language/zipf.md" \
        "$SKILLS_DIR/language/zipf.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable language skill carries Zipf optimization guidance" {
    CAT=language KEYWORDS=zipfs-law GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-language/SKILL.md"

    grep -qF '# Language: Zipf optimization' "$skill"
    grep -qF 'Identify the audience, task, and representative corpus' "$skill"
    grep -qF 'Choose one familiar canonical term' "$skill"
    grep -qF 'only when meaning survives' "$skill"
    grep -qF 'Put common action words and decision cues early' "$skill"
    grep -qF 'Measure the result with the intended audience' "$skill"
    grep -qF 'Spend rare vocabulary on information, not style' "$skill"
    grep -qF 'Raw word counts are treated as a readability or quality score' \
        "$skill"
    grep -qF "Zipf's law is an empirical approximation" "$skill"
    grep -qF 'forcing text toward a Zipfian' "$skill"
}
