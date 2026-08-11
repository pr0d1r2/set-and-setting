#!/usr/bin/env bats

@test "linter skill documents the pinned-check workflow" {
    local skill="$BATS_TEST_DIRNAME/../set/skills/generic/linter.md"

    grep -q 'Every file type tracked in git must have an assigned check' "$skill"
    grep -q 'nix-lefthook-<tool>-src' "$skill"
    grep -q 'lib.mk<Tool>Check' "$skill"
    grep -q 'lib/check-fragment-map.nix' "$skill"
    grep -q 'checksFor' "$skill"
    grep -q '<tool>-catches-violation' "$skill"
    grep -q 'lefthook.yml.*assembled artifact' "$skill"
    grep -q 'setting/integrations/lefthook/' "$skill"
    grep -q 'suffices.*null' "$skill"
    grep -q 'checkFlag.*""' "$skill"

    run grep -n 'both pre-commit and pre-push\|Add a command.*lefthook.yml\|{staged_files}\|all tracked files' "$skill"
    [ "$status" -eq 1 ]
}
