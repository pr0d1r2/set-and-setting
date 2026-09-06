#!/usr/bin/env bats
# lib/mk-consumer-flake-bats-probe.sh -- the consumer check's runtime half
# (B92/T82).
#
# The probe exists to catch a runner that cannot run anything: plain `pkgs.bats`
# in a wrapper's runtimeInputs leaves BATS_LIB_PATH unset, and every spec then
# dies in `setup` having asserted nothing. So what matters here is that the
# probe FAILS when the runner does -- a probe that passes regardless would have
# certified the defect it exists to find.

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert

    PROBE="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)/lib/mk-consumer-flake-bats-probe.sh"
    TMP="$(mktemp -d)"
    BIN="$TMP/bin"
    mkdir -p "$BIN"

    # git exports these into every hook it runs, and this spec runs under
    # pre-commit. Inherited, the probe's `git init`/`git add` would write the
    # index of the repository being committed rather than its own fixture.
    unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_PREFIX
    unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
}

teardown() { rm -rf "$TMP"; }

# A stub runner printing $1 and exiting $2.
_runner() {
    printf '#!/usr/bin/env bash\nprintf "%%s\\n" %q\nexit %s\n' "$1" "$2" \
        >"$BIN/lefthook-bats-unit"
    chmod +x "$BIN/lefthook-bats-unit"
}

_run_probe() { PATH="$BIN:$PATH" run bash "$PROBE"; }

@test "the probe exists" { [ -f "$PROBE" ]; }

@test "B92: a runner whose spec passes satisfies the probe" {
    _runner "ok 1 libraries resolve" 0
    _run_probe
    assert_success
}

@test "B92: a runner that FAILS fails the probe, and its output is shown" {
    # The measured shape: bats runs, and every spec dies in setup.
    _runner "not ok 1 libraries resolve
# bats_load_safe: Could not find '/usr/lib/bats/bats-support/load.bash'" 1
    _run_probe
    assert_failure
    assert_output --partial "could not run a spec"
    assert_output --partial "bats-support/load.bash"
}

@test "B92: a runner that exits 0 without running the spec still fails" {
    # Exit status alone is not evidence: a runner that discovers nothing and
    # says so cheerfully is exactly the false green this probe answers.
    _runner "1..0" 0
    _run_probe
    assert_failure
    assert_output --partial "did not pass through"
}

@test "T82: the fixture spec is TRACKED, or the runner would discover nothing" {
    # The runner finds specs with `git ls-files`, so an untracked fixture would
    # make every probe vacuously green.
    printf '#!/usr/bin/env bash\ngit ls-files > %q\nprintf "ok 1 libraries resolve\\n"\n' \
        "$TMP/tracked" >"$BIN/lefthook-bats-unit"
    chmod +x "$BIN/lefthook-bats-unit"
    _run_probe
    assert_success
    run cat "$TMP/tracked"
    assert_output --partial "tests/unit/probe.bats"
}

@test "T82: the fixture loads the libraries the way these repositories do" {
    printf '#!/usr/bin/env bash\ncat tests/unit/probe.bats > %q\nprintf "ok 1 libraries resolve\\n"\n' \
        "$TMP/spec" >"$BIN/lefthook-bats-unit"
    chmod +x "$BIN/lefthook-bats-unit"
    _run_probe
    assert_success
    run cat "$TMP/spec"
    assert_output --partial 'load "${BATS_LIB_PATH}/bats-support/load.bash"'
}

@test "T82: the runner is invoked with BATS_LIB_PATH unset" {
    # Anything ambient would stand in for what the wrapper must bring itself.
    printf '#!/usr/bin/env bash\nprintf "LIB=[%%s]\\n" "${BATS_LIB_PATH:-}" > %q\nprintf "ok 1 libraries resolve\\n"\n' \
        "$TMP/env" >"$BIN/lefthook-bats-unit"
    chmod +x "$BIN/lefthook-bats-unit"
    BATS_LIB_PATH=/should/not/leak _run_probe
    assert_success
    run cat "$TMP/env"
    assert_output "LIB=[]"
}
