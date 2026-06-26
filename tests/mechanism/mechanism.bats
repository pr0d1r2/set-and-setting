#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031  # per-@test env vars; bats isolates each

# Mechanism probes (V31, T50, B3). Empirically confirm Claude Code's
# loading semantics that the multi-channel design (V17-V21, V29) rests
# on, instead of trusting docs. Each @test plants a marker in a .claude/
# fixture, drives headless `claude -p`, and asserts the SPEC-believed
# behaviour. A failing probe is a FINDING -> backprop to SPEC, not a
# blind fix.
#
# Gated: skips unless MECHANISM_PROBES=1 AND `claude` is on PATH, so it
# never burns tokens in normal lefthook/CI runs. Run deliberately:
#   MECHANISM_PROBES=1 bats tests/mechanism/

setup() {
    [ -n "${MECHANISM_PROBES:-}" ] || skip "set MECHANISM_PROBES=1 to run (uses claude + tokens)"
    command -v claude >/dev/null || skip "claude not on PATH"
    DIR="$BATS_TEST_DIRNAME"
    FIXTURE="$(mktemp -d)"
    export FIXTURE
}

teardown() {
    [ -n "${FIXTURE:-}" ] && rm -rf "$FIXTURE"
    return 0
}

@test "skill SKILL.md does NOT auto-load on a plain prompt (B2)" {
    VARIANT=skill TOKEN=MECHPROBE-skill bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" PROMPT="What is 2 plus 2? Reply briefly." bash "$DIR/probe.sh"
    [[ "$output" != *"MECHPROBE-skill"* ]]
}

@test "path-less rule loads always" {
    VARIANT=rule-pathless TOKEN=MECHPROBE-rule-pathless bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" PROMPT="What is 2 plus 2? Reply briefly." bash "$DIR/probe.sh"
    [[ "$output" == *"MECHPROBE-rule-pathless"* ]]
}

@test "path-scoped rule loads when reading a matching file" {
    VARIANT=rule-paths TOKEN=MECHPROBE-rule-paths bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" PROMPT="Read the file target.nix with your tools, then say what 2 plus 2 is." bash "$DIR/probe.sh"
    [[ "$output" == *"MECHPROBE-rule-paths"* ]]
}

@test "path-scoped rule loads when WRITING a matching file (G2)" {
    VARIANT=rule-paths TOKEN=MECHPROBE-rule-paths bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" PROMPT="Create a file new.nix containing { } then say what 2 plus 2 is." bash "$DIR/probe.sh"
    [[ "$output" == *"MECHPROBE-rule-paths"* ]]
}

@test "@-import recurses through CLAUDE.md (V29)" {
    VARIANT=at-recursion TOKEN=MECHPROBE-at-recursion bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" PROMPT="What is 2 plus 2? Reply briefly." bash "$DIR/probe.sh"
    [[ "$output" == *"MECHPROBE-at-recursion"* ]]
}

@test "@-import expands inside a rule file" {
    VARIANT=at-in-rule TOKEN=MECHPROBE-at-in-rule bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" PROMPT="What is 2 plus 2? Reply briefly." bash "$DIR/probe.sh"
    [[ "$output" == *"MECHPROBE-at-in-rule"* ]]
}

@test "symlinked rule loads" {
    VARIANT=symlink TOKEN=MECHPROBE-symlink bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" PROMPT="What is 2 plus 2? Reply briefly." bash "$DIR/probe.sh"
    [[ "$output" == *"MECHPROBE-symlink"* ]]
}

@test "skill with disable-model-invocation does NOT auto-load (dedup, V20)" {
    VARIANT=skill-disable-invocation TOKEN=MECHPROBE-skill-disable-invocation bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" PROMPT="What is 2 plus 2? Reply briefly." bash "$DIR/probe.sh"
    [[ "$output" != *"MECHPROBE-skill-disable-invocation"* ]]
}
