#!/usr/bin/env bats

@test "opensource protection skill requires PRs and passing CI for everyone" {
    local skill="$BATS_TEST_DIRNAME/../set/skills/opensource/protection.md"

    [ -f "$skill" ]
    grep -q 'pull requests are required, including for administrators' "$skill"
    grep -q 'every status context reported by the repository.*is required' "$skill"
    grep -q -- '--from-standard' "$skill"
}
