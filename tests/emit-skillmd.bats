#!/usr/bin/env bats
# Unit coverage for emit-skillmd.sh -- portable SKILL.md channel (T47, V20).

setup() {
    bats_require_minimum_version 1.5.0
    SKILLS_DIR="$(mktemp -d)"
    SKILL_DEST="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../set/lib/emit-skillmd.sh"
    mkdir -p "$SKILLS_DIR/demo/sub"
    printf '# Demo\n\nCore body.\n' >"$SKILLS_DIR/demo.md"
    printf '# Demo: aspect\n\nAspect body.\n' >"$SKILLS_DIR/demo/aspect.md"
    # a supporting file that collides with SKILL.md on a case-insensitive FS
    printf '# Skill\n\nSkill body.\n' >"$SKILLS_DIR/demo/skill.md"
    export SKILLS_DIR SKILL_DEST COND_FIELD=paths EXCLUDE=""
}

teardown() {
    rm -rf "$SKILLS_DIR" "$SKILL_DEST"
    return 0
}

@test "emits set-<cat>/SKILL.md with frontmatter name + description + globs" {
    CAT=demo KEYWORDS="alpha,beta" GLOBS="**/*.nix" run bash "$SCRIPT"
    [ -f "$SKILL_DEST/set-demo/SKILL.md" ]
    run cat "$SKILL_DEST/set-demo/SKILL.md"
    [[ "$output" == *"name: set-demo"* ]]
    [[ "$output" == *"alpha, beta"* ]]
    [[ "$output" == *'"**/*.nix"'* ]]
}

@test "inlines category bodies verbatim" {
    CAT=demo KEYWORDS="demo" GLOBS="**/*" run bash "$SCRIPT"
    run cat "$SKILL_DEST/set-demo/SKILL.md"
    [[ "$output" == *"Core body."* ]]
    [[ "$output" == *"Aspect body."* ]]
    [[ "$output" == *"Skill body."* ]]
}

@test "survives a skill.md supporting file (case-insensitive FS collision)" {
    CAT=demo KEYWORDS="demo" GLOBS="**/*" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    # SKILL.md is the manifest (has frontmatter), not the skill.md content
    run head -1 "$SKILL_DEST/set-demo/SKILL.md"
    [ "$output" = "---" ]
}

@test "exclude omits a file's content" {
    CAT=demo KEYWORDS="demo" GLOBS="**/*" EXCLUDE="aspect.md" run bash "$SCRIPT"
    run cat "$SKILL_DEST/set-demo/SKILL.md"
    [[ "$output" != *"Aspect body."* ]]
    [[ "$output" == *"Core body."* ]]
}

@test "globs are not shell-expanded against cwd" {
    cd "$SKILL_DEST"
    mkdir -p sub && touch sub/x.nix
    CAT=demo KEYWORDS="demo" GLOBS="**/*" run bash "$SCRIPT"
    run grep -c '"\*\*/\*"' "$SKILL_DEST/set-demo/SKILL.md"
    [ "$output" = "1" ]
}
