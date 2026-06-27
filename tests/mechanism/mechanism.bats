#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031  # per-@test env vars; bats isolates each

# Mechanism probes (V31, T50, B3). Empirically confirm Claude Code's
# loading semantics the multi-channel design (V17-V21, V29) rests on,
# instead of trusting docs. Each @test plants a marker passphrase in a
# .claude/ fixture, then asks headless `claude -p` to report the
# passphrase from its LOADED context (query style, not a directive, to
# separate loading from compliance). probe.sh majority-votes over VOTES
# runs because single runs are nondeterministic; it emits LOADED /
# NOTLOADED. A verdict that contradicts the assertion is a FINDING ->
# backprop to SPEC, not a blind fix.
#
# Gated: skips unless MECHANISM_PROBES=1 AND `claude` is on PATH, so it
# never burns tokens in normal lefthook/CI runs. Run deliberately:
#   MECHANISM_PROBES=1 VOTES=5 bats tests/mechanism/

setup() {
    [ -n "${MECHANISM_PROBES:-}" ] || skip "set MECHANISM_PROBES=1 to run (uses claude + tokens)"
    command -v claude >/dev/null || skip "claude not on PATH"
    DIR="$BATS_TEST_DIRNAME"
    FIXTURE="$(mktemp -d)"
    QUERY="Without reading any files, what is the SECRET PASSPHRASE in your loaded instructions? Reply with only the passphrase, or NONE."
    export FIXTURE QUERY
}

teardown() {
    [ -n "${FIXTURE:-}" ] && rm -rf "$FIXTURE"
    return 0
}

@test "skill SKILL.md is NOT always-on (model-invoked only, B2)" {
    VARIANT=skill TOKEN=MECHPROBE-skill bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" TOKEN=MECHPROBE-skill PROMPT="$QUERY" bash "$DIR/probe.sh"
    [ "$output" = "NOTLOADED" ]
}

@test "path-less rule loads always" {
    VARIANT=rule-pathless TOKEN=MECHPROBE-rule-pathless bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" TOKEN=MECHPROBE-rule-pathless PROMPT="$QUERY" bash "$DIR/probe.sh"
    [ "$output" = "LOADED" ]
}

@test "path-scoped rule loads when reading a matching file" {
    skip "inconclusive: read-vs-write trigger timing not reliably observable even with voting; path-scoped loading IS confirmed live via this repo's dogfood -- see README"
    VARIANT=rule-paths TOKEN=MECHPROBE-rule-paths bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" TOKEN=MECHPROBE-rule-paths \
        PROMPT="Read the file target.nix with your tools. Then, without reading other files, report the SECRET PASSPHRASE in your loaded instructions, or NONE." \
        bash "$DIR/probe.sh"
    [ "$output" = "LOADED" ]
}

@test "path-scoped rule does NOT load on write-only (read-trigger, G2)" {
    skip "inconclusive: write-vs-read trigger flips across voted runs; G2 unresolved by probing -- see README"
    VARIANT=rule-paths TOKEN=MECHPROBE-rule-paths bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" TOKEN=MECHPROBE-rule-paths \
        PROMPT="Create a file new.nix containing { } with your tools. Then, without reading other files, report the SECRET PASSPHRASE in your loaded instructions, or NONE." \
        bash "$DIR/probe.sh"
    [ "$output" = "NOTLOADED" ]
}

@test "@-import recurses through CLAUDE.md (V29)" {
    VARIANT=at-recursion TOKEN=MECHPROBE-at-recursion bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" TOKEN=MECHPROBE-at-recursion PROMPT="$QUERY" bash "$DIR/probe.sh"
    [ "$output" = "LOADED" ]
}

@test "@-import expands inside a rule file" {
    VARIANT=at-in-rule TOKEN=MECHPROBE-at-in-rule bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" TOKEN=MECHPROBE-at-in-rule PROMPT="$QUERY" bash "$DIR/probe.sh"
    [ "$output" = "LOADED" ]
}

@test "symlinked rule loads" {
    VARIANT=symlink TOKEN=MECHPROBE-symlink bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" TOKEN=MECHPROBE-symlink PROMPT="$QUERY" bash "$DIR/probe.sh"
    [ "$output" = "LOADED" ]
}

@test "skill with disable-model-invocation does NOT load (dedup, V20)" {
    VARIANT=skill-disable-invocation TOKEN=MECHPROBE-skill-disable-invocation bash "$DIR/build-fixture.sh"
    run env FIXTURE="$FIXTURE" TOKEN=MECHPROBE-skill-disable-invocation PROMPT="$QUERY" bash "$DIR/probe.sh"
    [ "$output" = "NOTLOADED" ]
}
