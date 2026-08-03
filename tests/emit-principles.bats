#!/usr/bin/env bats

setup() {
    bats_require_minimum_version 1.5.0
    PRINCIPLES_DIR="$(mktemp -d)"
    OUT="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-principles.sh"
    export PRINCIPLES_DIR DEST="$OUT/principles-projection.md"
}

teardown() {
    rm -rf "$PRINCIPLES_DIR" "$OUT"
}

@test "projects every principle as name, slug, and one-line rule" {
    printf '# DRY\n\nDo not repeat\nyourself.\n\n## Detail\n\nIgnored.\n' \
        >"$PRINCIPLES_DIR/dry.md"
    printf '# Reality\n\nBase decisions on observed facts.\n' \
        >"$PRINCIPLES_DIR/reality.md"

    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q '^# Active principles$' "$DEST"
    grep -q '\[\[dry\]\].*DRY.*Do not repeat yourself\.' "$DEST"
    grep -q '\[\[reality\]\].*Reality.*Base decisions on observed facts\.' "$DEST"
    grep -q '^## Accord lens: principles$' "$DEST"
    grep -q 'objective violation blocks accord' "$DEST"
    grep -q 'weight evidence by relevant demonstrated track record' "$DEST"
}

@test "new files auto-enroll without a registry list" {
    printf '# First\n\nFirst rule.\n' >"$PRINCIPLES_DIR/first.md"
    bash "$SCRIPT"
    grep -q '\[\[first\]\]' "$DEST"

    printf '# New\n\nNew rule.\n' >"$PRINCIPLES_DIR/new.md"
    bash "$SCRIPT"
    grep -q '\[\[new\]\]' "$DEST"
}

@test "Parkinson's Law auto-enrolls with its citation slug" {
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/parkinson.md" \
        "$PRINCIPLES_DIR/parkinson.md"

    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q "\[\[parkinson\]\].*Parkinson's Law.*Work expands" "$DEST"
}

@test "Finagle's Law auto-enrolls with its citation slug" {
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/finagle.md" \
        "$PRINCIPLES_DIR/finagle.md"

    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q "\[\[finagle\]\].*Finagle's Law.*worst possible moment" "$DEST"
}

@test "Hofstadter's Law auto-enrolls with its citation slug" {
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/hofstadter.md" \
        "$PRINCIPLES_DIR/hofstadter.md"

    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q "\[\[hofstadter\]\].*Hofstadter's Law.*longer than you expect" \
        "$DEST"
}

@test "empty principle directory is a no-op" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ ! -e "$DEST" ]
}

@test "rejects a slug that is not one lowercase word" {
    printf '# Bad\n\nBad rule.\n' >"$PRINCIPLES_DIR/not-valid.md"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"must be one lowercase word"* ]]
    [ ! -e "$DEST" ]
}

@test "rejects missing principle metadata" {
    printf 'No heading.\n' >"$PRINCIPLES_DIR/bad.md"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"has no H1 name"* ]]
    [ ! -e "$DEST" ]
}

@test "rejects a principle with no opening prose rule" {
    printf '# Bad\n\n## Applying Bad\n\n- Detail only.\n' \
        >"$PRINCIPLES_DIR/bad.md"
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"has no one-line rule"* ]]
    [ ! -e "$DEST" ]
}
