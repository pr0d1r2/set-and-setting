# Streamline

Every user-facing operation should be a single command. The user
should never need to know underlying tools, flags, paths, or
multi-step sequences. Minimal knowledge to interact: one command
lists what is available, one command does the thing.

## Principles

- **Zero setup.** Entering the repo activates everything. No manual
  installs, no "run X first." If something needs initializing, it
  auto-starts, or the first command that needs it triggers it.
- **One command, one outcome.** No manual pre-steps, no "first run X
  then Y."
- **Self-documenting.** Listing the commands shows each one with a
  description, and copy-paste from that listing works.
- **No tool leakage.** The user never invokes the underlying tools
  directly. The entry point wraps them.
- **Wizard over flags.** Interactive prompts instead of requiring
  users to know config file formats.
- **Fail with guidance.** When prerequisites are missing, print what
  to do -- not a raw tool error.
- **Progressive disclosure.** The top level stays short. Depth is
  revealed only when needed.

## When adding new functionality

1. Give it a single entry-point command before considering it done.
2. Keep the entry point thin -- it names a script or target and does
  not carry the logic itself.
3. Give it a one-line description that appears in the listing.
4. Group related commands so the top-level listing stays readable.
5. Check that the listing still reads cleanly.

The mechanism is whatever the repo already uses: a task runner, a
build target, or a flake app. This repo uses flake apps -- each one
is `nix run .#<app>` and supports `--help`, `--list`, and
`--dry-run`. The task-runner form has its own category, with the
recipe, module, and script-extraction conventions.

## Anti-patterns

- Documenting raw commands in README instead of wrapping them
- Requiring env vars the user must set manually
- Multi-step instructions ("first do A, then B, then C")
- Manual setup steps ("install X, then configure Y")
- Silent failures -- always tell the user what went wrong and how to
  fix it
