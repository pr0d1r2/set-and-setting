# Lefthook: conditional

Conditional hooks run only when external prerequisites are met. They
skip silently (exit 0) when conditions fail -- never block a push due
to infrastructure being unavailable.

## Pattern

```bash
# Check prerequisites -- skip silently if not met
if ! ssh -o BatchMode=yes -o ConnectTimeout=3 "$host" true 2>/dev/null; then
    exit 0
fi

# Prerequisites met -- run the real check
exec bash "$REPO_ROOT/scripts/actual-test.sh"
```

Key rules:
- Exit 0 on missing prerequisites (not exit 1 -- that would fail the
  hook)
- Use short timeouts for SSH reachability checks (3s, not default 30s)
- `BatchMode=yes` -- never prompt for password interactively

## When to add a new conditional hook

1. Create script following the pattern above
2. Add to `lefthook.yml` under `pre-push` commands
3. Place after unconditional checks -- conditional hooks should be last
4. Add unit test with stub prerequisites
5. Unit tests must use a fake `REPO_ROOT` with only the files the
   script needs -- never invoke real builds

## Ordering in lefthook.yml

Conditional hooks run in parallel with other pre-push checks. Place
them after mandatory checks so the output reads naturally: fast checks
first, slow conditional checks last.
