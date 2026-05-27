# Streamline

Every user-facing operation should be a single `just` command.
The user should never need to know underlying tools, flags, paths,
or multi-step sequences. Minimal knowledge to interact:

    just              # list everything available
    just <cmd>        # do the thing

## Principles

- **Zero setup.** Entering the repo activates everything via
  direnv. No manual installs, no "run X first."
  Lefthook installs hooks automatically. If something needs
  initializing, it auto-starts or the first command that needs
  it triggers it.
- **One command, one outcome.** No manual pre-steps, no "first
  run X then Y."
- **Self-documenting.** `just --list` shows all commands with
  descriptions. Copy-paste from the listing works.
- **No tool leakage.** User never runs nix, qemu, ssh, rsync,
  expect, or iptables directly. Just wraps all of them.
- **Wizard over flags.** Interactive prompts instead of requiring
  users to know config file formats.
- **Fail with guidance.** When prerequisites are missing, print
  what to do -- not a raw tool error.
- **Progressive disclosure.** `just` shows top-level. Namespaced
  commands reveal depth only when needed.

## When adding new functionality

1. Wrap it in a `just` recipe before considering it done
2. Put the logic in a separate script -- recipe body is only
   `bash scripts/just/<module>/<script>.sh`
3. Add a one-line comment above the recipe (shows in `--list`)
4. Group related recipes in module files
5. Test that `just --list` stays clean and alphabetical

## Anti-patterns

- Documenting raw commands in README instead of wrapping in just
- Requiring env vars the user must set manually
- Multi-step instructions ("first do A, then B, then C")
- Manual setup steps ("install X, then configure Y")
- Silent failures -- always tell user what went wrong and how to fix
