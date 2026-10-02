#!/usr/bin/env bats
# Contract coverage for the multiple-approaches principle (#495).

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

@test "multiple approaches requires comparison and edge-case exploration" {
    cp "$BATS_TEST_DIRNAME/../set/skills/principles/approaches.md" \
        "$PRINCIPLES_DIR/approaches.md"

    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    grep -q "\[\[approaches\]\].*Multiple approaches.*first plausible solution" \
        "$DEST"
    grep -q 'Produce at least one credible alternative' \
        "$PRINCIPLES_DIR/approaches.md"
    grep -q 'Vary the dimensions that could change the answer' \
        "$PRINCIPLES_DIR/approaches.md"
    grep -q 'Stop exploring when additional candidates add no useful information' \
        "$PRINCIPLES_DIR/approaches.md"
}
