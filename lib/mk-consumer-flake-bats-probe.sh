# shellcheck shell=bash
# Prove a consumer's bats runner can actually run a spec (B92, T82).
#
# The runner is on PATH via the probe's runtimeInputs, which is the consumer's
# situation exactly: a writeShellApplication puts its own bats ahead of
# everything, so whatever it bundles is the only bats a spec will ever see. With
# plain `pkgs.bats` that bats has no libraries, BATS_LIB_PATH is unset, and every
# spec dies in `setup` having asserted nothing -- measured at 13 of 13 on the
# first consumer whose CI reached the runner.
#
# The fixture loads the libraries the way these repositories do, and runs with
# BATS_LIB_PATH unset so nothing ambient can stand in for what the wrapper is
# supposed to bring.
#
# NOTE: sourced by writeShellApplication -- no shebang or set needed.

work="$(mktemp -d)"
cd "$work" || exit 1

mkdir -p tests/unit
cat >tests/unit/probe.bats <<'SPEC'
#!/usr/bin/env bats
setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}
@test "libraries resolve" {
    run echo hi
    assert_output "hi"
}
SPEC

# The runner discovers specs with `git ls-files`, so the fixture must be a git
# repository and the spec must be tracked.
git init -q .
git config user.email probe@example.com
git config user.name probe
git add -A

if ! env -u BATS_LIB_PATH lefthook-bats-unit >out 2>&1; then
  echo "FAIL: the consumer's bats runner could not run a spec:"
  cat out
  exit 1
fi

if ! grep -q "ok 1 libraries resolve" out; then
  echo "FAIL: the spec did not pass through the consumer's runner:"
  cat out
  exit 1
fi
