#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for set/lib/app-mk-set.sh -- runnable installer for mkSet.
# Category selection (V27), run-time emit (V28), fail-with-guidance.

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    CONCEPTS_DIR="$(mktemp -d)"
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/app-mk-set.sh"

    mkdir -p "$SKILLS_DIR/generic"
    printf '# Generic\n\nGeneric skill.\n' >"$SKILLS_DIR/generic.md"
    printf '# Skill\n\nSkill rule.\n' >"$SKILLS_DIR/generic/skill.md"

    mkdir -p "$SKILLS_DIR/git"
    printf '# Git\n\nGit rule.\n' >"$SKILLS_DIR/git.md"
    printf '# Git: branch\n\nBranch rule.\n' >"$SKILLS_DIR/git/branch.md"

    mkdir -p "$SKILLS_DIR/nix"
    printf '# Nix\n\nNix rule.\n' >"$SKILLS_DIR/nix.md"
    printf '# Nix: flake\n\nFlake rule.\n' >"$SKILLS_DIR/nix/flake.md"

    mkdir -p "$SKILLS_DIR/security"
    printf '# Security\n\nSecurity rule.\n' >"$SKILLS_DIR/security.md"

    printf '# User\n\nUser concept.\n' >"$CONCEPTS_DIR/user.md"

    export SKILLS_DIR CONCEPTS_DIR
    export MK_SET_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/mk-set.sh"
    export EMIT_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skill.sh"
    export SYNC_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/sync-set.sh"
    export ALL_CATEGORIES="generic git nix security"
    export CORE_CATEGORIES="generic git"
    export GLOBS_MAP="nix=**/*.nix,flake.lock"
}

teardown() {
    rm -rf "$SKILLS_DIR" "$CONCEPTS_DIR" "$TARGET"
}

@test "--help shows usage and exits 0" {
    run bash "$SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: mkSet"* ]]
    [[ "$output" == *"--list"* ]]
    [[ "$output" == *"--dry-run"* ]]
    [[ "$output" == *"--all"* ]]
}

@test "--list shows all categories with core label" {
    run bash "$SCRIPT" --list
    [ "$status" -eq 0 ]
    [[ "$output" == *"generic (core)"* ]]
    [[ "$output" == *"git (core)"* ]]
    [[ "$output" == *"nix"* ]]
    [[ "$output" == *"security"* ]]
}

@test "--dry-run shows categories without writing files" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would install"* ]]
    [[ "$output" == *"generic git"* ]]
    [ ! -d "$TARGET/.claude" ]
}

@test "default mode installs core categories and shows notice" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing core categories"* ]]
    [[ "$output" == *"Additional categories available"* ]]
    [[ "$output" == *"Installed categories: generic git"* ]]
    [ -f "$TARGET/.claude/rules/generic.md" ]
}

@test "positional args add categories to core" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
    [ -f "$TARGET/.claude/skills/set/nix/SKILL.md" ]
    [ -f "$TARGET/.claude/rules/generic.md" ]
}

@test "--all installs all categories" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --all"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix security"* ]]
    [ -f "$TARGET/.claude/rules/generic.md" ]
    [ -f "$TARGET/.claude/skills/set/nix/SKILL.md" ]
    [ -f "$TARGET/.claude/rules/security.md" ]
}

@test "--all-except excludes listed categories" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --all-except security"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
    [ -f "$TARGET/.claude/rules/generic.md" ]
    [ -f "$TARGET/.claude/skills/set/nix/SKILL.md" ]
    [ ! -f "$TARGET/.claude/rules/security.md" ]
}

@test "unknown category fails with guidance" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' bogus"
    [ "$status" -eq 1 ]
    [[ "$output" == *"error: unknown category 'bogus'"* ]]
    [[ "$output" == *"Available categories"* ]]
}

@test "unknown option fails with guidance" {
    run bash "$SCRIPT" --bogus
    [ "$status" -eq 1 ]
    [[ "$output" == *"error: unknown option"* ]]
}

@test "unknown category in --all-except fails with guidance" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --all-except bogus"
    [ "$status" -eq 1 ]
    [[ "$output" == *"error: unknown category 'bogus'"* ]]
}

@test "core category as positional arg is not duplicated" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' generic nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
}

@test "concepts are included in output" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.claude/rules/concepts-user.md" ]
}

@test "clean-replace removes stale set files (V26)" {
    mkdir -p "$TARGET/.claude/skills/set/stale"
    echo "stale" >"$TARGET/.claude/skills/set/stale/SKILL.md"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    [ ! -e "$TARGET/.claude/skills/set/stale" ]
    [ -f "$TARGET/.claude/skills/set/nix/SKILL.md" ]
}

@test "writes manifest after install" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.claude/skills/set/.mkset.json" ]
    grep -q '"categories"' "$TARGET/.claude/skills/set/.mkset.json"
    grep -q '"generic"' "$TARGET/.claude/skills/set/.mkset.json"
    grep -q '"nix"' "$TARGET/.claude/skills/set/.mkset.json"
    grep -q '"rev"' "$TARGET/.claude/skills/set/.mkset.json"
    grep -q '"agent":"claude"' "$TARGET/.claude/skills/set/.mkset.json"
}

@test "bare re-run with manifest refreshes installed categories" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.claude/skills/set/.mkset.json" ]
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Refreshing from manifest"* ]]
    [[ "$output" == *"nix"* ]]
    [ -f "$TARGET/.claude/skills/set/nix/SKILL.md" ]
}

@test "bare re-run detects upstream update" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    sed -i 's/"rev":"[^"]*"/"rev":"oldrev"/' "$TARGET/.claude/skills/set/.mkset.json"
    export MKSET_REV="newrev"
    run bash -c "cd '$TARGET' && MKSET_REV=newrev bash '$SCRIPT'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Update detected: oldrev -> newrev"* ]]
}

@test "--remove removes categories and updates manifest" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix security"
    [ "$status" -eq 0 ]
    grep -q '"nix"' "$TARGET/.claude/skills/set/.mkset.json"
    grep -q '"security"' "$TARGET/.claude/skills/set/.mkset.json"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --remove nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Removed: nix"* ]]
    run ! grep -q '"nix"' "$TARGET/.claude/skills/set/.mkset.json"
    grep -q '"security"' "$TARGET/.claude/skills/set/.mkset.json"
    [ ! -e "$TARGET/.claude/skills/set/nix" ]
}

@test "--remove fails on core category" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --remove generic"
    [ "$status" -eq 1 ]
    [[ "$output" == *"cannot remove core category"* ]]
}

@test "--remove fails without manifest" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --remove nix"
    [ "$status" -eq 1 ]
    [[ "$output" == *"no manifest found"* ]]
}

@test "--remove fails on unknown category" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --remove bogus"
    [ "$status" -eq 1 ]
    [[ "$output" == *"error: unknown category 'bogus'"* ]]
}

@test "--remove with --dry-run shows what would happen" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix security"
    [ "$status" -eq 0 ]
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --dry-run --remove nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Would remove: nix"* ]]
    [[ "$output" == *"Would keep"* ]]
    grep -q '"nix"' "$TARGET/.claude/skills/set/.mkset.json"
}

@test "--remove requires at least one category" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --remove"
    [ "$status" -eq 1 ]
    [[ "$output" == *"--remove requires at least one category"* ]]
}
