# Ops: destructive

Detect and guard destructive operations — commands that delete data,
overwrite state, or cannot be reversed.

## Signals

- Commands containing: `rm`, `drop`, `delete`, `reset --hard`,
  `push --force`, `truncate`, `destroy`.
- File operations on paths outside working directory.
- Database mutations without transaction wrapper.
- Git operations that rewrite published history.

## Rules

- Destructive commands require explicit confirmation before execution.
- Agent tooling should classify commands as safe/destructive before
  running.
- Wrap destructive operations with dry-run preview: show what would
  change before executing.
- Log all destructive operations with timestamp and user for audit.
