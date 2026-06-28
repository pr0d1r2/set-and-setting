#!/usr/bin/env bats
# --auto smart materialization end-to-end (T53, V34/V37): the app scans the
# consumer repo (git ls-files) and emits only skills with evidence, then
# records the applicability evidence in the manifest.

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    CONCEPTS_DIR="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/app-mk-set.sh"

    # fixture skill tree: core generic, domain nix + lefthook, facet qemu
    mkdir -p "$SKILLS_DIR/generic" "$SKILLS_DIR/nix" \
        "$SKILLS_DIR/lefthook" "$SKILLS_DIR/test"
    printf '# Generic\n\nrule\n' >"$SKILLS_DIR/generic.md"
    printf '# Skill\n\nrule\n' >"$SKILLS_DIR/generic/skill.md"
    printf '# Nix\n\nrule\n' >"$SKILLS_DIR/nix.md"
    printf '# Flake\n\nrule\n' >"$SKILLS_DIR/nix/flake.md"
    printf '# Lefthook\n\nrule\n' >"$SKILLS_DIR/lefthook.md"
    printf '# Glob\n\nrule\n' >"$SKILLS_DIR/lefthook/glob.md"
    printf '# QEMU\n\nrule\n' >"$SKILLS_DIR/test/qemu.md"
    printf '# User\n\nconcept\n' >"$CONCEPTS_DIR/user.md"

    export SKILLS_DIR CONCEPTS_DIR
    export MK_SET_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/mk-set.sh"
    export EMIT_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skill.sh"
    export EMIT_RULE_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-rule.sh"
    export APPLICABILITY_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/applicability.sh"
    export AUTO_KEEP_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/app-auto-keep.sh"
    export SYNC_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/sync-set.sh"
    export RESOLVE_AGENT_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/resolve-agent.sh"
    export ALL_CATEGORIES="generic nix lefthook test"
    export CORE_CATEGORIES="generic"
    export GLOBS_MAP="nix=**/*.nix,flake.lock;generic=**/*;lefthook=lefthook.yml;test=**/*.bats"
    export CHANNEL_OVERRIDES="test/qemu.md||tests/integration/**,**/*.exp"
    export AGENT_SEAMS="claude=.claude/rules/set,paths;opencode=.opencode/rules/set,globs"
    SIGNALS_MANIFEST="$(printf '%s\n' \
        'generic.md|**/*|' \
        'generic/skill.md|**/*|' \
        'nix.md|**/*.nix,flake.lock|' \
        'nix/flake.md|**/*.nix,flake.lock|' \
        'lefthook.md|lefthook.yml|' \
        'lefthook/glob.md|lefthook.yml|' \
        'test/qemu.md|tests/integration/**,**/*.exp|qemu,enable-kvm')"
    export SIGNALS_MANIFEST
}

teardown() {
    rm -rf "$SKILLS_DIR" "$CONCEPTS_DIR" "$TARGET"
    return 0
}

@test "--auto installs only skills with repo evidence + records manifest" {
    cd "$TARGET" || return 1
    git init -q
    printf '{ }\n' >flake.nix
    mkdir -p tests/integration
    printf 'spawn qemu -enable-kvm\n' >tests/integration/boot.exp
    git add -A

    run bash "$SCRIPT" --auto
    [ "$status" -eq 0 ]

    set="$TARGET/.claude/rules/set"
    # core + nix (flake.nix) + qemu (content) kept
    [ -f "$set/generic/skill.md" ]
    [ -f "$set/nix/flake.md" ]
    [ -f "$set/test/qemu.md" ]
    # lefthook pruned (no lefthook.yml)
    [ ! -f "$set/lefthook/glob.md" ]
    [ ! -f "$set/lefthook.md" ]

    # manifest records applicability evidence (V37)
    manifest="$set/.mkset.json"
    [ -f "$manifest" ]
    grep -q '"applicability"' "$manifest"
    grep -q '"test/qemu.md":"content:qemu,enable-kvm"' "$manifest"
    grep -q '"generic/skill.md":"core"' "$manifest"
}

@test "--auto in a repo without evidence keeps only core" {
    cd "$TARGET" || return 1
    git init -q
    printf '# readme\n' >README.md
    git add -A

    run bash "$SCRIPT" --auto
    [ "$status" -eq 0 ]
    set="$TARGET/.claude/rules/set"
    [ -f "$set/generic/skill.md" ]
    [ ! -f "$set/nix/flake.md" ]
    [ ! -f "$set/test/qemu.md" ]
}

@test "--auto --dry-run lists applicable skills without writing" {
    cd "$TARGET" || return 1
    git init -q
    printf '{ }\n' >flake.nix
    git add -A

    run bash "$SCRIPT" --auto --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"nix/flake.md"* ]]
    [ ! -d "$TARGET/.claude" ]
}
