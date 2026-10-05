#!/usr/bin/env bats
# narrow-language is retired (#474); its unread dictionaries are gone (#490).

setup() {
    bats_require_minimum_version 1.5.0
    ROOT="$BATS_TEST_DIRNAME/.."
}

@test "no tracked-style narrow-language dictionary sits at the repo root" {
    run find "$ROOT" -maxdepth 1 -name '.narrow-language-*.dic'
    [ -z "$output" ]
}

@test "no integration fragment runs narrow-language" {
    run ! grep -rq 'narrow-language' "$ROOT/setting/integrations"
}

@test "the skill says the hook is retired by default" {
    grep -q '^## Status: retired by default' "$ROOT/set/skills/language/narrow.md"
}
