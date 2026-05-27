# CI: use full commit SHA in GitHub Actions workflows

Always pin actions to full 40-character commit SHA, not short SHA
or tags.

## Why

GitHub Actions rejects short SHAs:

```
Error: Unable to resolve action `owner/action@fbeb9d9`,
the provided ref `fbeb9d9` is the shortened version of a
commit SHA, which is not supported.
```

Tags (`@v4`, `@main`) are mutable — can be force-pushed. Full SHA
is immutable and auditable.

## Correct

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd
- uses: pr0d1r2/nix-lefthook-ci-action@fbeb9d9cfe38488df1ccfbe220179aa9390fb074
```

## Wrong

```yaml
- uses: actions/checkout@v4          # mutable tag
- uses: pr0d1r2/action@fbeb9d9      # short SHA rejected
- uses: pr0d1r2/action@main         # mutable branch
```

## How to get full SHA

```bash
git ls-remote https://github.com/owner/repo refs/heads/main
```

Or from a local clone:

```bash
git rev-parse HEAD
```
