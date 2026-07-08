#!/usr/bin/env bats
# Unit coverage for lib/ref-match.sh -- the @-ref matcher (T63). Emits ONLY
# real @-references (leading-token @set/... / @concepts/... / relative
# @<cat>/<file>.md) and skips code spans/fences, block HTML comments, and
# non-ref @ tokens (emails, git SHAs, prose @main/@include). The
# false-positive filter that unblocked T58.
# shellcheck disable=SC2030,SC2031,SC2016  # single-quoted @refs/backticks are literals

setup() {
    bats_require_minimum_version 1.5.0
    DIR="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/ref-match.sh"
    FIX="$DIR/in.md"
}

teardown() {
    rm -rf "$DIR"
    return 0
}

# --- real refs are emitted ---------------------------------------------

@test "leading @set/ ref is emitted" {
    printf '@set/skills/git/commit.md\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@set/skills/git/commit.md" ]
}

@test "leading @concepts/ ref is emitted" {
    printf '@concepts/hardware/apple/m4.md\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@concepts/hardware/apple/m4.md" ]
}

@test "relative @<category>/<file>.md ref is emitted" {
    printf '@language/active.md\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@language/active.md" ]
}

@test "leading whitespace before a ref is allowed" {
    printf '   @set/drafts/agent/anatomy.md\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@set/drafts/agent/anatomy.md" ]
}

@test "multiple refs across lines emit in order" {
    printf '@language/narrow.md\n@language/active.md\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "@language/narrow.md" ]
    [ "${lines[1]}" = "@language/active.md" ]
    [ "${#lines[@]}" -eq 2 ]
}

@test "@set/ ref without .md suffix still counts (leading-token form)" {
    printf '@set/skills/git\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@set/skills/git" ]
}

# --- non-ref @ tokens are skipped --------------------------------------

@test "email @example.com is skipped (no slash)" {
    printf 'contact user@example.com for info\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "git short SHA @fbeb9d9 is skipped" {
    printf 'owner/action@fbeb9d9\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "git full SHA is skipped" {
    printf 'pr0d1r2/ci-action@fbeb9d9cfe38488df1ccfbe220179aa9390fb074\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "prose @main / @v4 mutable tags are skipped" {
    printf 'Tags like @main and @v4 are mutable.\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "action ref foo@main (non-word-initial @) is skipped" {
    printf '  - uses: DeterminateSystems/nix-installer-action@main\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "systemd @system-service / @privileged are skipped" {
    printf 'SystemCallFilter = [ "@system-service" "~@privileged" ];\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "prose @include (no slash) is skipped" {
    printf 'awk on macOS lacks @include support.\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "top-level @file.md without a category dir is skipped" {
    printf '@readme.md\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# --- code spans and fences are skipped ---------------------------------

@test "ref inside an inline code span is skipped" {
    printf 'The `@language/active.md` token is illustrative.\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "ref inside a fenced code block is skipped" {
    printf '```\n@set/skills/git/commit.md\n```\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "ref inside a tilde-fenced block is skipped" {
    printf '~~~\n@set/skills/git/commit.md\n~~~\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "real ref outside a code span on a mixed line is emitted" {
    printf '@set/a.md and `@set/ignored.md` in a span\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@set/a.md" ]
}

@test "refs resume after a fenced block closes" {
    printf '```\n@set/inside.md\n```\n@set/outside.md\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@set/outside.md" ]
}

# --- HTML comments are stripped ----------------------------------------

@test "ref inside a single-line HTML comment is skipped" {
    printf '<!-- @set/skills/git/commit.md -->\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "ref inside a multi-line HTML comment is skipped" {
    printf '<!--\n@set/skills/git/commit.md\n-->\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "ref after a closed comment on the same line is emitted" {
    printf '<!-- note --> @set/after.md\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@set/after.md" ]
}

# --- robustness --------------------------------------------------------

@test "glob-like ref path is not expanded against the CWD" {
    # A literal @-token containing * must be emitted verbatim, not globbed.
    printf '@set/rules/**/*.md\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@set/rules/**/*.md" ]
}

@test "trailing prose punctuation is trimmed from a ref" {
    printf 'See @set/a.md, then stop.\n' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@set/a.md" ]
}

@test "empty file emits nothing" {
    printf '' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "file with a final line lacking a trailing newline is scanned" {
    printf '@set/no-newline.md' >"$FIX"
    INPUT="$FIX" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$output" = "@set/no-newline.md" ]
}
