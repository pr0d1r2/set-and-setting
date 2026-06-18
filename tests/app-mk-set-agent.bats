#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

# Unit tests for --agent seam passthrough in app-mk-set.sh (T39/V21/V23).
# Proves agent-agnostic emission: same source, different target paths.

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
    export RESOLVE_AGENT_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/resolve-agent.sh"
    export ALL_CATEGORIES="generic git nix security"
    export CORE_CATEGORIES="generic git"
    export GLOBS_MAP="nix=**/*.nix,flake.lock"
    export AGENT_SEAMS="claude=.claude/skills/set,.claude/rules,paths;opencode=.opencode/skills/set,.opencode/rules,globs"
}

teardown() {
    rm -rf "$SKILLS_DIR" "$CONCEPTS_DIR" "$TARGET"
}

@test "--agent opencode emits to opencode paths" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
    [ -f "$TARGET/.opencode/rules/generic.md" ]
    [ -f "$TARGET/.opencode/skills/set/nix/SKILL.md" ]
    [ ! -d "$TARGET/.claude" ]
}

@test "--agent opencode uses globs in frontmatter" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    grep -q '^globs:' "$TARGET/.opencode/skills/set/nix/SKILL.md"
    run ! grep -q '^paths:' "$TARGET/.opencode/skills/set/nix/SKILL.md"
}

@test "--agent opencode manifest records opencode" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.opencode/skills/set/.mkset.json" ]
    grep -q '"agent":"opencode"' "$TARGET/.opencode/skills/set/.mkset.json"
}

@test "--agent opencode dry-run shows opencode target" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Agent: opencode"* ]]
    [[ "$output" == *"Target: ./.opencode/skills/set/"* ]]
}

@test "--agent unknown fails with guidance" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent bogus"
    [ "$status" -eq 1 ]
    [[ "$output" == *"error: unknown agent 'bogus'"* ]]
    [[ "$output" == *"Available agents"* ]]
}

@test "--agent without name fails" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent"
    [ "$status" -eq 1 ]
    [[ "$output" == *"error: --agent requires a name"* ]]
}

@test "--agent opencode same body as claude (V23)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    claude_body="$(sed '1,/^---$/d' "$TARGET/.claude/skills/set/nix/SKILL.md")"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    opencode_body="$(sed '1,/^---$/d' "$TARGET/.opencode/skills/set/nix/SKILL.md")"
    [ "$claude_body" = "$opencode_body" ]
}

@test "--agent opencode concepts go to opencode rules" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.opencode/rules/concepts-user.md" ]
    [ ! -d "$TARGET/.claude" ]
}
