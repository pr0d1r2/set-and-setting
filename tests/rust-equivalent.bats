#!/usr/bin/env bats
# Contract coverage for Rust guidance (#286, #426).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/principles"
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/rust.md" \
        "$SKILLS_DIR/principles/rust.md"
    export SKILLS_DIR SKILL_DEST SCRIPT
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
}

@test "portable principle carries Rust equivalent guidance" {
    CAT=principles KEYWORDS=rust-equivalent GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-principles/SKILL.md"

    grep -qF '# Rust equivalent' "$skill"
    grep -qF 'Search the Rust ecosystem before adopting' "$skill"
    grep -qF 'Compare candidates on the workload that matters' "$skill"
    grep -qF 'Validate promising candidates with representative' "$skill"
    grep -qF 'spike.' "$skill"
    grep -qF 'Measure the current option too' "$skill"
    grep -qF 'Rust is a search heuristic, not a performance guarantee' \
        "$skill"
    grep -qF 'See also [[sutton]] and [[nih]]' "$skill"
}

@test "Rust gating policy is a language skill with no Rust lint fragments" {
    mkdir -p "$SKILLS_DIR/language"
    cp "$BATS_TEST_DIRNAME/../set/skills/language/language.md" \
        "$SKILLS_DIR/language/language.md"
    cp "$BATS_TEST_DIRNAME/../set/skills/language/rust.md" \
        "$SKILLS_DIR/language/rust.md"

    CAT=language KEYWORDS=rust GLOBS='**/*' \
        COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-language/SKILL.md"

    grep -qF '# Rust' "$skill"
    grep -qF 'Rust repositories are `hk`-gated by design' "$skill"
    grep -qF '`hk check`' "$skill"
    grep -qF 'mkSet' "$skill"
    grep -qF 'mkSetting' "$skill"
    grep -qF 'never emits Rust lint fragments' "$skill"
}

@test "Rust has no standard lefthook checks or coverage obligations" {
    map="$BATS_TEST_DIRNAME/../lib/check-fragment-map.nix"
    run nix --extra-experimental-features nix-command eval --json \
        --file "$map" validFragments
    [ "$status" -eq 0 ]
    ! grep -qE 'clippy|rustfmt|cargo' <<<"$output"

    run nix --extra-experimental-features nix-command eval --json \
        --file "$map" coveragePerFileClass
    [ "$status" -eq 0 ]
    ! grep -qE 'clippy|rustfmt|cargo' <<<"$output"
}
