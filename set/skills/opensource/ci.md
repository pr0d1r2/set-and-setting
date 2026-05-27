# Open-source: CI

CI runs both locally (lefthook pre-push hooks) and hosted (GitHub
Actions via `nix-lefthook-ci-action`).

## Local CI

- Lefthook pre-push hooks enforce the same checks as hosted CI
- `lefthook.yml` is the single source of truth for all checks
- Developers must be in `nix develop` shell for hooks to work

## Hosted CI with nix-lefthook-ci-action

All open-source nix repos use `nix-lefthook-ci-action` for GitHub
Actions. The action bundles: nix installer, cachix, nix build,
lefthook pre-commit + pre-push.

Three-platform structure:

```
build-linux (lint + build x86_64) ──> build-darwin (macos runner)
                                  └──> build-linux-arm (QEMU aarch64)
```

Linux gates the expensive jobs. See `ci/multi-platform-gate` skill.

## Standard workflow

```yaml
---
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: pr0d1r2/nix-lefthook-ci-action@SHA
        with:
          cachix-auth-token: ${{ secrets.CACHIX_AUTH_TOKEN }}

  build-darwin:
    needs: build-linux
    runs-on: macos-latest
    steps:
      - uses: pr0d1r2/nix-lefthook-ci-action@SHA
        with:
          cachix-auth-token: ${{ secrets.CACHIX_AUTH_TOKEN }}

  build-linux-arm:
    needs: build-linux
    runs-on: ubuntu-latest
    steps:
      - uses: pr0d1r2/nix-lefthook-ci-action@SHA
        with:
          extra-platforms: aarch64-linux
          cachix-auth-token: ${{ secrets.CACHIX_AUTH_TOKEN }}
```

Pin action to full commit SHA per `ci/full-commit-sha` skill.

## Required secrets

- `CACHIX_AUTH_TOKEN` — set via `gh secret set CACHIX_AUTH_TOKEN`
- `GITHUB_TOKEN` — automatic, use via `pre-build-commands` for
  repos with many inputs (see `ci/github-actions-token` skill)

## Lefthook hooks as the primary gate

CI is a safety net. Lefthook hooks are the gatekeeper. Both run
the same checks — CI catches what a developer skips locally.
