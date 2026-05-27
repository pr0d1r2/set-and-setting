# Lefthook: skip pitfalls

## Orphan skip in wrong stage

A remote defines `narrow-language-nix-compact` in `pre-commit` only.
If your local `lefthook.yml` adds `skip: true` for it in `pre-push`,
lefthook creates a job with no `run` field:

```
🥊 narrow-language-nix-compact: either `run`,`script`, or `group`
   must be provided for a job
```

Fix: only add `skip: true` overrides for hooks that exist in that
stage's remote config. Check the remote's `lefthook-remote.yml` to
see which stages define which hooks.

## skip: true with empty config in pre-commit

In pre-commit, `skip: true` merges with the remote's `run` field
and works. But only because the remote defines the hook there.
Same override in a stage where the remote doesn't define the hook
creates an orphan entry with no run command.

## Safer pattern

When unsure if a hook exists in a stage, use `skip: true` only
in pre-commit where you know the remote defines it. For pre-push,
check the remote config first or omit the override entirely.
