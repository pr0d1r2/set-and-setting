#!/usr/bin/env bats
# The git skill describes durable change records without requesting private
# reasoning extraction or a transcript of the agent's internal process.

setup() {
    bats_require_minimum_version 1.5.0
    SKILL="$BATS_TEST_DIRNAME/../set/skills/git/git.md"
}

@test "git skill requires focused commits and factual evidence" {
    run cat "$SKILL"
    [ "$status" -eq 0 ]
    [[ "$output" == *"small, atomic steps"* ]]
    [[ "$output" == *"durable work record"* ]]
    [[ "$output" == *"check or evidence"* ]]
    [[ "$output" == *"durable project memory"* ]]
}

@test "git skill explicitly avoids private reasoning transcripts" {
    run cat "$SKILL"
    [ "$status" -eq 0 ]
    [[ "$output" == *"not as a transcript of private reasoning"* ]]
    [[ "$output" != *"commit message carries the reasoning"* ]]
    [[ "$output" != *"observe decisions made"* ]]
}
