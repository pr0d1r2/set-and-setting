# Ops: slash

Package common operations into a tree of composable commands using
`ops/<domain>/<verb>.sh` convention. Replaces scattered shell aliases
with discoverable, testable scripts.

## Structure

```text
ops/
  git/
    clone.sh
    sync.sh
  tmp/
    run.sh
  nix/
    update.sh
    check.sh
```

## Rules

- Each script is standalone — no sourcing other scripts, no shared
  state.
- Scripts accept positional args. First arg is always the primary
  target.
- Composable via pipeline: `ops/tmp/run.sh ops/git/clone.sh user/repo`.
- Scripts are testable with bats.
- Destructive scripts must prompt for confirmation unless `--force`
  flag is passed.
- Ingest existing shell alias collections (git_shell_aliases etc.)
  by extracting each alias into its own script under the appropriate
  domain.
