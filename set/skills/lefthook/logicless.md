# Lefthook: logicless

Lefthook `run:` fields must be plain commands with no embedded logic.
No conditionals, subshells, command substitutions, ternary-style
fallbacks, or platform detection belongs in `lefthook.yml`.

## Anti-pattern

```yaml
run: timeout "${LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT:-$(if [ "$(uname -s)" = "Darwin" ]; then echo 120; else echo 60; fi)}" nix flake check
```

This embeds platform detection, nested command substitution, and
default-value logic in a YAML one-liner -- unreadable, untestable,
and brittle.

## Correct approach

Extract to a shell script and invoke it:

```yaml
run: bash scripts/lefthook/nix-flake-check.sh {staged_files}
```

The script handles logic, defaults, and platform differences:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname -s)" = "Darwin" ]; then
  default_timeout=120
else
  default_timeout=60
fi

timeout "${LEFTHOOK_NIX_FLAKE_CHECK_TIMEOUT:-$default_timeout}" nix flake check
```

## Why

- Testable: the script can be unit-tested with bats
- Readable: logic has proper indentation and comments
- Portable: shellcheck catches errors that YAML quoting hides
- Debuggable: run the script directly to reproduce failures
