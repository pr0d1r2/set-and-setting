#!/usr/bin/env bats
# Contract coverage for the actionable flake modularization skill (#198).

setup() {
    bats_require_minimum_version 1.5.0
    SKILL_DEST="$(mktemp -d)"
    SKILLS_DIR="$BATS_TEST_DIRNAME/../set/skills"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    export SKILL_DEST SKILLS_DIR SCRIPT
}

teardown() {
    rm -rf "$SKILL_DEST"
}

@test "portable nix skill carries the flake modularization method" {
    CAT=nix KEYWORDS=nix GLOBS='**/*.nix' COND_FIELD=paths bash "$SCRIPT"
    skill="$SKILL_DEST/set-nix/SKILL.md"

    grep -qF 'outputs = inputs: import ./flake inputs;' "$skill"
    grep -qF 'Use a directory for multiple independent, same-shaped leaves.' "$skill"
    grep -qF 'Use `builtins.readDir` only for bulk-uniform internal leaves' "$skill"
    grep -qF 'Preserve every public output attribute byte-for-byte' "$skill"
    grep -qF 'sibling leaf, such as importing `../apps/x.nix` from a check' "$skill"
    grep -qF 'flake/hooks/registry.nix' "$skill"
    grep -qF 'devshells/           # one cohesive default.nix builder' "$skill"
}
