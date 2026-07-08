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
    export EMIT_RULE_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-rule.sh"
    export SYNC_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/sync-set.sh"
    export RESOLVE_AGENT_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/resolve-agent.sh"
    export ALL_CATEGORIES="generic git nix security"
    export CORE_CATEGORIES="generic git"
    export GLOBS_MAP="nix=**/*.nix,flake.lock;generic=**/*;git=**/*;security=**/*"
    export CHANNEL_OVERRIDES=""
    export AGENT_SEAMS="claude=.claude/rules/set,paths,.claude/skills,1,@,CLAUDE.md,path-rules;opencode=.opencode/rules/set,globs,.,0,inline,AGENTS.md,opencode.json-instructions;caveman-code=.cave/rules/set,paths,.cave/skills,1,@,CAVE.md,path-rules;cursor=.cursor/rules/set,globs,.,0,inline,AGENTS.md,cursor-rules;codex=.codex/rules/set,globs,.,0,inline,AGENTS.md,none;gemini-cli=.gemini/rules/set,globs,.,0,inline,AGENTS.md,none;copilot=.copilot/rules/set,globs,.,0,inline,AGENTS.md,none;amp=.amp/rules/set,globs,.,0,inline,AGENTS.md,none"
    export EMIT_SKILLMD_SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    export KEYWORDS_MAP="generic=generic;git=git;nix=nix;security=security"
    export COMPILER_SCRIPT="$BATS_TEST_DIRNAME/../lib/agents-md-compile.sh"
}

teardown() {
    rm -rf "$SKILLS_DIR" "$CONCEPTS_DIR" "$TARGET"
}

@test "--agent opencode emits to opencode paths" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
    [ -f "$TARGET/.opencode/rules/set/generic/skill.md" ]
    [ -f "$TARGET/.opencode/rules/set/nix/flake.md" ]
    [ ! -d "$TARGET/.claude" ]
}

@test "--agent opencode uses globs in frontmatter" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    grep -q '^globs:' "$TARGET/.opencode/rules/set/nix/flake.md"
    run ! grep -q '^paths:' "$TARGET/.opencode/rules/set/nix/flake.md"
}

@test "--agent opencode manifest records opencode" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.opencode/rules/set/.mkset.json" ]
    grep -q '"agent":"opencode"' "$TARGET/.opencode/rules/set/.mkset.json"
}

@test "--agent opencode dry-run shows opencode target" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Agent: opencode"* ]]
    [[ "$output" == *"Target: ./.opencode/rules/set/"* ]]
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
    claude_body="$(sed '1,/^---$/d' "$TARGET/.claude/rules/set/nix/flake.md")"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    opencode_body="$(sed '1,/^---$/d' "$TARGET/.opencode/rules/set/nix/flake.md")"
    [ "$claude_body" = "$opencode_body" ]
}

@test "--agent opencode concepts go to opencode rules" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.opencode/rules/set/concepts-user.md" ]
    [ ! -d "$TARGET/.claude" ]
}

@test "--agent opencode emits AGENTS.md (V39)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/AGENTS.md" ]
    grep -q 'Generic skill' "$TARGET/AGENTS.md"
}

@test "--agent opencode emits opencode.json (V39)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/opencode.json" ]
    grep -q '"instructions": \["AGENTS.md"\]' "$TARGET/opencode.json"
}

@test "--agent opencode emits portable SKILL.md at root (V20)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent opencode nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/set-nix/SKILL.md" ]
    run ! grep -q 'disable-model-invocation' "$TARGET/set-nix/SKILL.md"
}

@test "--agent claude emits SKILL.md with dedup (V20)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.claude/skills/set-nix/SKILL.md" ]
    grep -q 'disable-model-invocation: true' "$TARGET/.claude/skills/set-nix/SKILL.md"
}

@test "--agent claude does not emit AGENTS.md or opencode.json" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    [ ! -f "$TARGET/AGENTS.md" ]
    [ ! -f "$TARGET/opencode.json" ]
}

@test "--agent caveman-code emits to .cave paths" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent caveman-code nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
    [ -f "$TARGET/.cave/rules/set/generic/skill.md" ]
    [ -f "$TARGET/.cave/rules/set/nix/flake.md" ]
    [ ! -d "$TARGET/.claude" ]
    [ ! -d "$TARGET/.opencode" ]
}

@test "--agent caveman-code uses paths in frontmatter" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent caveman-code nix"
    [ "$status" -eq 0 ]
    grep -q '^paths:' "$TARGET/.cave/rules/set/nix/flake.md"
    run ! grep -q '^globs:' "$TARGET/.cave/rules/set/nix/flake.md"
}

@test "--agent caveman-code manifest records caveman-code" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent caveman-code nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.cave/rules/set/.mkset.json" ]
    grep -q '"agent":"caveman-code"' "$TARGET/.cave/rules/set/.mkset.json"
}

@test "--agent caveman-code dry-run shows caveman target" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent caveman-code --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Agent: caveman-code"* ]]
    [[ "$output" == *"Target: ./.cave/rules/set/"* ]]
}

@test "--agent caveman-code same body as claude (V23)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    claude_body="$(sed '1,/^---$/d' "$TARGET/.claude/rules/set/nix/flake.md")"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent caveman-code nix"
    [ "$status" -eq 0 ]
    caveman_body="$(sed '1,/^---$/d' "$TARGET/.cave/rules/set/nix/flake.md")"
    [ "$claude_body" = "$caveman_body" ]
}

@test "--agent caveman-code emits SKILL.md with dedup (V20)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent caveman-code nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.cave/skills/set-nix/SKILL.md" ]
    grep -q 'disable-model-invocation: true' "$TARGET/.cave/skills/set-nix/SKILL.md"
}

@test "--agent caveman-code does not emit AGENTS.md or opencode.json" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent caveman-code nix"
    [ "$status" -eq 0 ]
    [ ! -f "$TARGET/AGENTS.md" ]
    [ ! -f "$TARGET/opencode.json" ]
}

@test "--agent caveman-code concepts go to .cave rules" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent caveman-code"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.cave/rules/set/concepts-user.md" ]
    [ ! -d "$TARGET/.claude" ]
}

# --- T34 extension agents: cursor, codex, gemini-cli, copilot, amp ---

@test "--agent cursor emits to .cursor paths" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent cursor nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
    [ -f "$TARGET/.cursor/rules/set/generic/skill.md" ]
    [ -f "$TARGET/.cursor/rules/set/nix/flake.md" ]
    [ ! -d "$TARGET/.claude" ]
}

@test "--agent cursor uses globs in frontmatter" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent cursor nix"
    [ "$status" -eq 0 ]
    grep -q '^globs:' "$TARGET/.cursor/rules/set/nix/flake.md"
    run ! grep -q '^paths:' "$TARGET/.cursor/rules/set/nix/flake.md"
}

@test "--agent cursor manifest records cursor" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent cursor nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.cursor/rules/set/.mkset.json" ]
    grep -q '"agent":"cursor"' "$TARGET/.cursor/rules/set/.mkset.json"
}

@test "--agent cursor dry-run shows cursor target" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent cursor --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Agent: cursor"* ]]
    [[ "$output" == *"Target: ./.cursor/rules/set/"* ]]
}

@test "--agent cursor same body as claude (V23)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    claude_body="$(sed '1,/^---$/d' "$TARGET/.claude/rules/set/nix/flake.md")"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent cursor nix"
    [ "$status" -eq 0 ]
    cursor_body="$(sed '1,/^---$/d' "$TARGET/.cursor/rules/set/nix/flake.md")"
    [ "$claude_body" = "$cursor_body" ]
}

@test "--agent cursor emits AGENTS.md" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent cursor nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/AGENTS.md" ]
    grep -q 'Generic skill' "$TARGET/AGENTS.md"
}

@test "--agent cursor does not emit opencode.json" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent cursor nix"
    [ "$status" -eq 0 ]
    [ ! -f "$TARGET/opencode.json" ]
}

@test "--agent codex emits to .codex paths" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent codex nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
    [ -f "$TARGET/.codex/rules/set/generic/skill.md" ]
    [ -f "$TARGET/.codex/rules/set/nix/flake.md" ]
    [ ! -d "$TARGET/.claude" ]
}

@test "--agent codex uses globs in frontmatter" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent codex nix"
    [ "$status" -eq 0 ]
    grep -q '^globs:' "$TARGET/.codex/rules/set/nix/flake.md"
    run ! grep -q '^paths:' "$TARGET/.codex/rules/set/nix/flake.md"
}

@test "--agent codex manifest records codex" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent codex nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/.codex/rules/set/.mkset.json" ]
    grep -q '"agent":"codex"' "$TARGET/.codex/rules/set/.mkset.json"
}

@test "--agent codex same body as claude (V23)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    claude_body="$(sed '1,/^---$/d' "$TARGET/.claude/rules/set/nix/flake.md")"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent codex nix"
    [ "$status" -eq 0 ]
    codex_body="$(sed '1,/^---$/d' "$TARGET/.codex/rules/set/nix/flake.md")"
    [ "$claude_body" = "$codex_body" ]
}

@test "--agent codex emits AGENTS.md" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent codex nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/AGENTS.md" ]
}

@test "--agent codex does not emit opencode.json" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent codex nix"
    [ "$status" -eq 0 ]
    [ ! -f "$TARGET/opencode.json" ]
}

@test "--agent gemini-cli emits to .gemini paths" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent gemini-cli nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
    [ -f "$TARGET/.gemini/rules/set/generic/skill.md" ]
    [ -f "$TARGET/.gemini/rules/set/nix/flake.md" ]
    [ ! -d "$TARGET/.claude" ]
}

@test "--agent gemini-cli uses globs in frontmatter" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent gemini-cli nix"
    [ "$status" -eq 0 ]
    grep -q '^globs:' "$TARGET/.gemini/rules/set/nix/flake.md"
}

@test "--agent gemini-cli manifest records gemini-cli" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent gemini-cli nix"
    [ "$status" -eq 0 ]
    grep -q '"agent":"gemini-cli"' "$TARGET/.gemini/rules/set/.mkset.json"
}

@test "--agent gemini-cli same body as claude (V23)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    claude_body="$(sed '1,/^---$/d' "$TARGET/.claude/rules/set/nix/flake.md")"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent gemini-cli nix"
    [ "$status" -eq 0 ]
    gemini_body="$(sed '1,/^---$/d' "$TARGET/.gemini/rules/set/nix/flake.md")"
    [ "$claude_body" = "$gemini_body" ]
}

@test "--agent copilot emits to .copilot paths" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent copilot nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
    [ -f "$TARGET/.copilot/rules/set/generic/skill.md" ]
    [ -f "$TARGET/.copilot/rules/set/nix/flake.md" ]
    [ ! -d "$TARGET/.claude" ]
}

@test "--agent copilot uses globs in frontmatter" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent copilot nix"
    [ "$status" -eq 0 ]
    grep -q '^globs:' "$TARGET/.copilot/rules/set/nix/flake.md"
}

@test "--agent copilot manifest records copilot" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent copilot nix"
    [ "$status" -eq 0 ]
    grep -q '"agent":"copilot"' "$TARGET/.copilot/rules/set/.mkset.json"
}

@test "--agent copilot same body as claude (V23)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    claude_body="$(sed '1,/^---$/d' "$TARGET/.claude/rules/set/nix/flake.md")"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent copilot nix"
    [ "$status" -eq 0 ]
    copilot_body="$(sed '1,/^---$/d' "$TARGET/.copilot/rules/set/nix/flake.md")"
    [ "$claude_body" = "$copilot_body" ]
}

@test "--agent amp emits to .amp paths" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent amp nix"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installed categories: generic git nix"* ]]
    [ -f "$TARGET/.amp/rules/set/generic/skill.md" ]
    [ -f "$TARGET/.amp/rules/set/nix/flake.md" ]
    [ ! -d "$TARGET/.claude" ]
}

@test "--agent amp uses globs in frontmatter" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent amp nix"
    [ "$status" -eq 0 ]
    grep -q '^globs:' "$TARGET/.amp/rules/set/nix/flake.md"
}

@test "--agent amp manifest records amp" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent amp nix"
    [ "$status" -eq 0 ]
    grep -q '"agent":"amp"' "$TARGET/.amp/rules/set/.mkset.json"
}

@test "--agent amp same body as claude (V23)" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' nix"
    [ "$status" -eq 0 ]
    claude_body="$(sed '1,/^---$/d' "$TARGET/.claude/rules/set/nix/flake.md")"
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent amp nix"
    [ "$status" -eq 0 ]
    amp_body="$(sed '1,/^---$/d' "$TARGET/.amp/rules/set/nix/flake.md")"
    [ "$claude_body" = "$amp_body" ]
}

@test "--agent amp emits AGENTS.md" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent amp nix"
    [ "$status" -eq 0 ]
    [ -f "$TARGET/AGENTS.md" ]
}

@test "--agent amp does not emit opencode.json" {
    run bash -c "cd '$TARGET' && bash '$SCRIPT' --agent amp nix"
    [ "$status" -eq 0 ]
    [ ! -f "$TARGET/opencode.json" ]
}
