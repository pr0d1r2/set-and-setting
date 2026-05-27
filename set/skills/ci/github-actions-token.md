# GitHub Actions: Nix flake access tokens

Nix flake repos with many GitHub inputs (30+ nix-lefthook-* etc.) exhaust
unauthenticated GitHub API quota (60 req/hr) during CI. Fetching fails
with HTTP 404 on tarball downloads.

## Fix

Use built-in `GITHUB_TOKEN` (auto-provisioned, 5000 req/hr, zero setup):

```yaml
env:
  NIX_CONFIG: access-tokens = github.com=${{ secrets.GITHUB_TOKEN }}
```

Set at workflow level for all jobs, or per-step for composite actions.

## Scope

- `GITHUB_TOKEN` is automatic in every Actions run — no secrets config needed
- Scoped to the repo, read-only for PRs from forks
- `NIX_CONFIG` env var is read by nix at runtime, works with any installer
  (DeterminateSystems, cachix/install-nix-action, etc.)

## When to apply

Any nix flake project with >10 GitHub inputs. Below that, unauthenticated
quota usually suffices.

## Gotcha: composite actions

`NIX_CONFIG` env var set on a composite action step does NOT propagate
into the composite action's internal sub-steps. The env is lost.

For composite actions like nix-lefthook-ci-action, write directly to
`/etc/nix/nix.conf` via `pre-build-commands` (runs after nix install,
before nix evaluate):

```yaml
- uses: pr0d1r2/nix-lefthook-ci-action@SHA
  with:
    pre-build-commands: |
      echo "access-tokens = github.com=${{ secrets.GITHUB_TOKEN }}" | sudo tee -a /etc/nix/nix.conf
```

This persists for all subsequent nix calls in the job.
