#!/usr/bin/env bats

# Unit tests for the rule extracted from set/skills/gnu/sed.md by
# `rekall apply`. Contract: BSD sed reaching executable content is a
# violation; prose naming it in order to forbid it is not, and neither is
# the rule quoting the statement it enforces.
#
# The rule reads the repository through `git grep`, so each test runs in a
# throwaway repository. It is installed at `.rekall/rules/` there because
# that is where `rekall apply` puts it, and the rule excludes that
# directory BY PATH -- a copy anywhere else would match its own quoted
# payload, which is a property of the fixture and not of the rule.

setup() {
    TMP="$(mktemp -d)"
    RULE="$BATS_TEST_DIRNAME/../../../.rekall/rules/always-use-sed-from-the-dev.sh"
    git init -q "$TMP"
    git -C "$TMP" config user.email t@example.com
    git -C "$TMP" config user.name t
    mkdir -p "$TMP/.rekall/rules"
    cp "$RULE" "$TMP/.rekall/rules/always-use-sed-from-the-dev.sh"
}

teardown() {
    rm -rf "$TMP"
}

run_rule() {
    git -C "$TMP" add -A
    run sh -c "cd \"$TMP\" && sh .rekall/rules/always-use-sed-from-the-dev.sh"
}

@test "a tree with no BSD sed is silent and exits 0" {
    printf '#!/bin/sh\nsed -i s/a/b/ f\n' >"$TMP/clean.sh"
    run_rule
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "an absolute BSD sed in a script is a violation" {
    printf '#!/bin/sh\n/usr/bin/sed -i "" s/a/b/ f\n' >"$TMP/bad.sh"
    run_rule
    [ "$status" -eq 1 ]
    [[ "$output" == *"BSD sed reached executable content"* ]]
    [[ "$output" == *"bad.sh"* ]]
}

@test "the BSD empty-suffix idiom is a violation on its own" {
    printf '#!/bin/sh\nsed -i %s s/a/b/ f\n' "''" >"$TMP/idiom.sh"
    run_rule
    [ "$status" -eq 1 ]
    [[ "$output" == *"idiom.sh"* ]]
}

@test "prose may name what it forbids" {
    mkdir -p "$TMP/set/skills/gnu"
    printf 'Never use `/usr/bin/sed`, which is BSD sed.\n' \
        >"$TMP/set/skills/gnu/awk.md"
    run_rule
    [ "$status" -eq 0 ]
}

@test "the rule does not fire on its own quoted statement" {
    run_rule
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "a nix or yaml file is read, not only shell" {
    printf 'script = "/usr/bin/sed -i s/a/b/";\n' >"$TMP/build.nix"
    run_rule
    [ "$status" -eq 1 ]
    [[ "$output" == *"build.nix"* ]]
}

@test "the message names the fix, not only the breach" {
    printf '#!/bin/sh\n/usr/bin/sed -i "" s/a/b/ f\n' >"$TMP/bad.sh"
    run_rule
    [[ "$output" == *"write \`sed -i\` without the BSD empty-suffix argument"* ]]
}
