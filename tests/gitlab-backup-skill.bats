#!/usr/bin/env bats

@test "GitLab backup skill documents conditional post-commit push" {
    local skill="$BATS_TEST_DIRNAME/../set/skills/git/repo/backup.md"

    grep -q 'post-commit' "$skill"
    grep -q 'git remote get-url gitlab' "$skill"
    grep -q 'git push gitlab "HEAD:refs/heads/\$branch"' "$skill"
    grep -q 'Do not force-push' "$skill"
}

@test "GitLab backup skill skips absent remotes and detached HEAD" {
    local skill="$BATS_TEST_DIRNAME/../set/skills/git/repo/backup.md"

    grep -q 'remote is absent' "$skill"
    grep -q 'checkout is detached' "$skill"
    grep -q 'failed backup push' "$skill"
}
