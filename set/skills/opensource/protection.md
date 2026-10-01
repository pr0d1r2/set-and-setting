# Open-source: branch protection

Protect the default branch so every change arrives through a pull request and
the repository's CI has passed before it can merge. Administrators follow the
same policy as every other role.

Use the repository's branch-protection app rather than constructing a GitHub
API payload by hand:

```bash
nix run github:pr0d1r2/set-and-setting#branch-protection -- \
  --from-standard --dry-run
```

Review the resolved required status contexts, then apply the policy after
explicit approval:

```bash
nix run github:pr0d1r2/set-and-setting#branch-protection -- \
  --from-standard
```

The resulting policy for `main` must have all of these properties:

- pull requests are required, including for administrators;
- every status context reported by the repository's CI is required and must be
  successful; and
- force pushes and branch deletion are disabled.

Run the dry-run again whenever CI job names change. Required status checks are
matched by their exact GitHub context names, so stale names can make a pull
request impossible to merge while missing names can weaken the gate.
