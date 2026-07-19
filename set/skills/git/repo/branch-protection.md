# Git repo: branch protection

Configure GitHub branch protection with the mechanical app instead of
constructing a `gh api` payload.

Preview the resolved repository, branch, and policy:

```bash
nix run github:pr0d1r2/set-and-setting#branch-protection -- --dry-run
```

After explicit human approval for the permission change, apply it:

```bash
nix run github:pr0d1r2/set-and-setting#branch-protection
```

Pass `--repo OWNER/REPO` outside a local checkout, `--branch BRANCH` for a
non-`main` branch, or `--status-checks CHECK_A,CHECK_B` to require named
checks. Run with `--help` for the complete interface.
