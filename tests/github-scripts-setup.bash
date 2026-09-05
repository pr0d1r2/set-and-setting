# Shared fixture for the .github/scripts specs (T81): a stubbed `nix` that
# records its argv, and a fake setting package whose sync-setting records too.
# The scripts are what CI runs, so the assertions are about the exact commands
# reaching the runner.

github_scripts_setup() {
    DIR="$(cd "$BATS_TEST_DIRNAME/../../../.github/scripts" && pwd)"
    TMP="$(mktemp -d)"
    LOG="$TMP/calls"
    BIN="$TMP/bin"
    mkdir -p "$BIN" "$TMP/setting/bin"
    {
        echo '#!/usr/bin/env bash'
        echo "printf 'nix %s\\n' \"\$*\" >>\"$LOG\""
        echo 'case "$*" in'
        echo "    *--print-out-paths*) echo \"$TMP/setting\" ;;"
        echo 'esac'
    } >"$BIN/nix"
    {
        echo '#!/usr/bin/env bash'
        echo "printf 'sync %s\\n' \"\$*\" >>\"$LOG\""
    } >"$TMP/setting/bin/sync-setting"
    chmod +x "$BIN/nix" "$TMP/setting/bin/sync-setting"
    PATH="$BIN:$PATH"
}
