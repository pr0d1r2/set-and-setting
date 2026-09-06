# Git repository: GitLab backup

When a checkout has a GitLab remote, keep it as an on-site backup of
every committed change. Configure the remote with the stable name
`gitlab`:

```sh
git remote add gitlab <gitlab-repository-url>
```

Install a `post-commit` hook that exits successfully without doing
anything when the `gitlab` remote is absent, the checkout is detached,
or the current branch has no name. Otherwise, push the commit that was
just created to the same branch on `gitlab`:

```sh
branch=$(git branch --show-current)
if git remote get-url gitlab >/dev/null 2>&1 && [ -n "$branch" ]; then
  git push gitlab "HEAD:refs/heads/$branch"
fi
```

Use the explicit refspec so the backup follows the branch that received
the commit, rather than whatever upstream happens to be configured.
Do not force-push or rewrite the backup. A failed backup push must be
reported clearly, but must not undo the local commit; retry it before
continuing work. The normal pre-push checks still apply to this push.
