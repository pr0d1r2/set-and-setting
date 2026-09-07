#!/usr/bin/env bats
# tests/git-env.bash -- the scrub a spec needs when bats runs inside a git hook.
#
# Git exports GIT_DIR into every hook it runs and this suite runs from
# pre-push, so a spec that cd's to a fixture and runs `git init` still
# addresses the repository being pushed: GIT_DIR outranks the working
# directory. What follows proves the scrub works and that every spec touching
# git actually loads it (B97).

setup() {
    bats_require_minimum_version 1.5.0
    HELPER="$BATS_TEST_DIRNAME/git-env.bash"
    TMP="$(mktemp -d)"

    # This spec is itself a victim when run from a hook.
    unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_PREFIX

    VICTIM="$TMP/victim"
    git init -q "$VICTIM"
    git -C "$VICTIM" -c user.email=v@v -c user.name=victim \
        commit -q --allow-empty -m "work worth keeping"
    VICTIM_HEAD="$(git -C "$VICTIM" rev-parse HEAD)"

    mkdir -p "$TMP/fixture"
}

teardown() { rm -rf "$TMP"; }

@test "the helper exists" {
    [ -f "$HELPER" ]
}

@test "an inherited GIT_DIR sends a fixture's commit to the real repository" {
    # The negative control: without the scrub the defect is real, so a pass
    # below means the scrub did it, not that the sequence was harmless.
    cd "$TMP/fixture" || return 1
    GIT_DIR="$VICTIM/.git" git init -q
    GIT_DIR="$VICTIM/.git" git -c user.email=f@f -c user.name=fixture \
        commit -q --allow-empty -m initial

    [ "$(git -C "$VICTIM" rev-parse HEAD)" != "$VICTIM_HEAD" ]
    [ "$(git -C "$VICTIM" log --oneline -1 --format=%s)" = "initial" ]
}

@test "the helper keeps a fixture's commit out of the real repository" {
    cd "$TMP/fixture" || return 1
    export GIT_DIR="$VICTIM/.git"
    # shellcheck source=/dev/null
    . "$HELPER"
    git init -q
    git -c user.email=f@f -c user.name=fixture commit -q --allow-empty -m initial

    [ "$(git -C "$VICTIM" rev-parse HEAD)" = "$VICTIM_HEAD" ]
}

@test "the helper keeps a fixture's identity out of the real config" {
    cd "$TMP/fixture" || return 1
    export GIT_DIR="$VICTIM/.git"
    # shellcheck source=/dev/null
    . "$HELPER"
    git init -q
    git config user.name Test
    git config user.email test@test.com

    run git -C "$VICTIM" config --local --get user.name
    [ "$status" -ne 0 ]
}

@test "the helper stops a worktree GIT_DIR marking the shared config bare" {
    # The loud half: a linked worktree's GIT_DIR does not end in /.git, so
    # `git init` cannot infer a work tree and marks the repository bare. That
    # config is shared, so the main checkout stops working entirely.
    git -C "$VICTIM" worktree add -q "$TMP/linked" -b side

    cd "$TMP/fixture" || return 1
    export GIT_DIR="$VICTIM/.git/worktrees/linked"
    # shellcheck source=/dev/null
    . "$HELPER"
    git init -q

    [ "$(git -C "$VICTIM" config --get core.bare)" = "false" ]
    git -C "$VICTIM" status --short
}

# Any git invocation, not only `git init` and friends: an inherited GIT_DIR
# misdirects a read as readily as a write, and it outranks `-C`, so
# `git -C "$fixture" init` reinitializes the repository being pushed (B98).
# Match git in command position so prose mentioning the word does not count.
GIT_CALL='(^|[;&|(]|\$\(|`|[[:space:]]run |[[:space:]]!)[[:space:]]*!?[[:space:]]*git[[:space:]]'

@test "every spec that runs git loads the helper" {
    cd "$BATS_TEST_DIRNAME/.." || return 1

    unloaded=""
    while IFS= read -r spec; do
        case "$spec" in tests/git-env.bats) continue ;; esac
        grep -Eq "$GIT_CALL" "$spec" || continue
        grep -q "git-env" "$spec" || unloaded="$unloaded $spec"
    done < <(git ls-files -- 'tests/*.bats' 'tests/**/*.bats')

    [ -z "$unloaded" ] || {
        echo "specs run git without loading tests/git-env.bash:$unloaded"
        return 1
    }
}

@test "the detector sees git behind -C and other options" {
    probe="$TMP/probe.bats"
    printf '%s\n' '    git -C "$TARGET" init' >"$probe"
    grep -Eq "$GIT_CALL" "$probe"

    printf '%s\n' '    run git -c user.name=x commit -m x' >"$probe"
    grep -Eq "$GIT_CALL" "$probe"
}

@test "the detector ignores prose that merely names git" {
    probe="$TMP/probe.bats"
    printf '%s\n' '# tracked in git must have a check' >"$probe"
    run ! grep -Eq "$GIT_CALL" "$probe"

    printf '%s\n' '@test "git short SHA is skipped" {' >"$probe"
    run ! grep -Eq "$GIT_CALL" "$probe"
}
