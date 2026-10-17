#!/usr/bin/env bats

setup() {
    bats_require_minimum_version 1.5.0
    SKILL="$BATS_TEST_DIRNAME/../set/skills/opensource/cachix.md"
}

@test "cachix skill standardizes the shared cache" {
    grep -qF 'https://pr0d1r2.cachix.org' "$SKILL"
    grep -qF 'pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=' "$SKILL"
    grep -qF 'name: pr0d1r2' "$SKILL"
    grep -qF 'CACHIX_AUTH_TOKEN' "$SKILL"
}

@test "cachix push cannot block a successful release" {
    grep -qF 'continue-on-error: true' "$SKILL"
    grep -qF 'after the outputs' "$SKILL"
    grep -qF 'already succeeded' "$SKILL"
    grep -qF 'Push only outputs whose inputs are public.' "$SKILL"
}

@test "cachix skill requires the action after a build" {
    awk '/- name: Build outputs/{build=NR} /- name: Push built paths/{push=NR} END{exit !(build && push && build < push)}' "$SKILL"
    grep -qF 'Use a full commit SHA for the action' "$SKILL"
    grep -qF "if: secrets.CACHIX_AUTH_TOKEN != ''" "$SKILL"
}
